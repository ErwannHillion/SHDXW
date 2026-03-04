defmodule Shdxw.Shop do
  @moduledoc """
  The Shop context. Manages shop items, purchases, and active boosts.
  """

  import Ecto.Query, warn: false
  alias Shdxw.Repo
  alias Shdxw.Accounts.Scope
  alias Shdxw.Shop.{ShopItem, UserItem}

  @topic_prefix "shop"

  defp topic(%Scope{user: user}), do: "#{@topic_prefix}:#{user.id}"

  def subscribe(%Scope{} = scope) do
    Phoenix.PubSub.subscribe(Shdxw.PubSub, topic(scope))
  end

  defp broadcast(%Scope{} = scope, event, payload) do
    Phoenix.PubSub.broadcast(Shdxw.PubSub, topic(scope), {event, payload})
  end

  def list_items(opts \\ []) do
    type_filter = Keyword.get(opts, :type)

    ShopItem
    |> where(active: true)
    |> maybe_filter_type(type_filter)
    |> order_by(asc: :level_required, asc: :price)
    |> Repo.all()
  end

  defp maybe_filter_type(query, nil), do: query
  defp maybe_filter_type(query, type), do: where(query, type: ^type)

  def get_item!(id), do: Repo.get!(ShopItem, id)

  def purchase_item(%Scope{} = scope, shop_item_id) do
    profile = Shdxw.Gamification.get_or_create_profile(scope)
    item = get_item!(shop_item_id)

    cond do
      profile.gold < item.price ->
        {:error, :insufficient_gold}

      profile.level < item.level_required ->
        {:error, :level_required}

      item.max_owned && count_owned(scope, shop_item_id) >= item.max_owned ->
        {:error, :max_owned}

      true ->
        # Deduct gold
        {:ok, _profile} = Shdxw.Gamification.spend_gold(scope, item.price)

        # Create or increment user item
        case Repo.get_by(UserItem, user_id: scope.user.id, shop_item_id: shop_item_id) do
          nil ->
            {:ok, user_item} =
              %UserItem{user_id: scope.user.id}
              |> UserItem.changeset(%{shop_item_id: shop_item_id, quantity: 1})
              |> Repo.insert()

            # Check achievements
            Shdxw.Achievements.check_and_award(scope, :shop)

            broadcast(scope, :item_purchased, %{user_item: user_item, shop_item: item})
            {:ok, user_item}

          existing ->
            {:ok, user_item} =
              existing
              |> UserItem.changeset(%{quantity: existing.quantity + 1})
              |> Repo.update()

            broadcast(scope, :item_purchased, %{user_item: user_item, shop_item: item})
            {:ok, user_item}
        end
    end
  end

  defp count_owned(%Scope{} = scope, shop_item_id) do
    from(ui in UserItem,
      where: ui.user_id == ^scope.user.id and ui.shop_item_id == ^shop_item_id,
      select: coalesce(sum(ui.quantity), 0)
    )
    |> Repo.one()
  end

  def activate_item(%Scope{} = scope, user_item_id) do
    user_item = Repo.get_by!(UserItem, id: user_item_id, user_id: scope.user.id)
    shop_item = get_item!(user_item.shop_item_id)

    if user_item.quantity > 0 do
      now = DateTime.utc_now() |> DateTime.truncate(:second)

      expires_at =
        if shop_item.duration_minutes do
          DateTime.add(now, shop_item.duration_minutes * 60, :second)
        end

      new_quantity = user_item.quantity - 1

      {:ok, updated} =
        user_item
        |> UserItem.changeset(%{
          active: true,
          activated_at: now,
          expires_at: expires_at,
          quantity: new_quantity
        })
        |> Repo.update()

      broadcast(scope, :item_activated, %{user_item: updated, shop_item: shop_item})
      {:ok, updated}
    else
      {:error, :no_items}
    end
  end

  def list_user_items(%Scope{} = scope) do
    from(ui in UserItem,
      where: ui.user_id == ^scope.user.id,
      join: si in ShopItem,
      on: ui.shop_item_id == si.id,
      preload: [shop_item: si],
      order_by: [desc: ui.inserted_at]
    )
    |> Repo.all()
  end

  def list_active_boosts(%Scope{} = scope) do
    now = DateTime.utc_now()

    from(ui in UserItem,
      where: ui.user_id == ^scope.user.id,
      where: ui.active == true,
      where: is_nil(ui.expires_at) or ui.expires_at > ^now,
      join: si in ShopItem,
      on: ui.shop_item_id == si.id,
      preload: [shop_item: si]
    )
    |> Repo.all()
  end

  def expire_items do
    now = DateTime.utc_now()

    from(ui in UserItem,
      where: ui.active == true,
      where: not is_nil(ui.expires_at),
      where: ui.expires_at <= ^now
    )
    |> Repo.update_all(set: [active: false])
  end
end
