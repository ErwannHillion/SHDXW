defmodule Shdxw.Skins do
  @moduledoc """
  The Skins context. Manages cosmetic skins with permanent XP/gold boosts.
  """

  import Ecto.Query, warn: false
  alias Shdxw.Repo
  alias Shdxw.Accounts.Scope
  alias Shdxw.Skins.{Skin, UserSkin}

  # --- Listing ---

  def list_skins do
    Skin
    |> where(active: true)
    |> order_by(asc: :rarity, asc: :price)
    |> Repo.all()
  end

  def list_user_skins(%Scope{} = scope) do
    from(us in UserSkin,
      where: us.user_id == ^scope.user.id,
      join: s in Skin,
      on: us.skin_id == s.id,
      preload: [skin: s],
      order_by: [desc: us.equipped, desc: us.inserted_at]
    )
    |> Repo.all()
  end

  def get_equipped_skin(%Scope{} = scope) do
    from(us in UserSkin,
      where: us.user_id == ^scope.user.id,
      where: us.equipped == true,
      join: s in Skin,
      on: us.skin_id == s.id,
      preload: [skin: s]
    )
    |> Repo.one()
  end

  # --- Purchase ---

  def purchase_skin(%Scope{} = scope, skin_id) do
    profile = Shdxw.Gamification.get_or_create_profile(scope)
    skin = Repo.get!(Skin, skin_id)

    already_owned =
      Repo.exists?(
        from(us in UserSkin,
          where: us.user_id == ^scope.user.id and us.skin_id == ^skin_id
        )
      )

    cond do
      already_owned ->
        {:error, :already_owned}

      profile.gold < skin.price ->
        {:error, :insufficient_gold}

      profile.level < skin.level_required ->
        {:error, :level_required}

      true ->
        {:ok, _} = Shdxw.Gamification.spend_gold(scope, skin.price)

        {:ok, user_skin} =
          %UserSkin{user_id: scope.user.id}
          |> UserSkin.changeset(%{skin_id: skin_id})
          |> Repo.insert()

        {:ok, Repo.preload(user_skin, :skin)}
    end
  end

  # --- Equip ---

  def equip_skin(%Scope{} = scope, user_skin_id) do
    Repo.transaction(fn ->
      # Unequip all current skins
      from(us in UserSkin,
        where: us.user_id == ^scope.user.id and us.equipped == true
      )
      |> Repo.update_all(set: [equipped: false])

      # Equip the selected one
      user_skin = Repo.get_by!(UserSkin, id: user_skin_id, user_id: scope.user.id)

      {:ok, equipped} =
        user_skin
        |> UserSkin.changeset(%{equipped: true})
        |> Repo.update()

      Repo.preload(equipped, :skin)
    end)
  end

  def unequip_skin(%Scope{} = scope) do
    from(us in UserSkin,
      where: us.user_id == ^scope.user.id and us.equipped == true
    )
    |> Repo.update_all(set: [equipped: false])

    :ok
  end

  # --- Boosts (used by Gamification) ---

  def get_skin_xp_boost(%Scope{} = scope) do
    case get_equipped_skin(scope) do
      nil -> 0
      user_skin -> user_skin.skin.xp_boost_percent
    end
  end

  def get_skin_gold_boost(%Scope{} = scope) do
    case get_equipped_skin(scope) do
      nil -> 0
      user_skin -> user_skin.skin.gold_boost_percent
    end
  end

  # --- Seed Data ---

  def seed_skins do
    skins = [
      %{name: "Ombre de Novice", description: "Un voile sombre pour les debutants.", icon: "🌑", rarity: :common, xp_boost_percent: 2, gold_boost_percent: 1, price: 50, level_required: 1, enchantment_slots: 1},
      %{name: "Flamme d'Apprenti", description: "Les flammes d'un apprenti determiné.", icon: "🔥", rarity: :common, xp_boost_percent: 3, gold_boost_percent: 2, price: 100, level_required: 3, enchantment_slots: 1},
      %{name: "Aura Cristalline", description: "Un éclat de cristal pur entoure votre avatar.", icon: "💎", rarity: :rare, xp_boost_percent: 5, gold_boost_percent: 4, price: 300, level_required: 5, enchantment_slots: 2},
      %{name: "Armure du Gardien", description: "L'armure ancestrale des gardiens du savoir.", icon: "🛡️", rarity: :rare, xp_boost_percent: 7, gold_boost_percent: 5, price: 500, level_required: 8, enchantment_slots: 2},
      %{name: "Cape de l'Eclipse", description: "Tissée dans l'obscurité d'une éclipse totale.", icon: "🌘", rarity: :epic, xp_boost_percent: 10, gold_boost_percent: 8, price: 1000, level_required: 12, enchantment_slots: 3},
      %{name: "Couronne de Foudre", description: "La foudre frappe ceux qui osent la porter.", icon: "⚡", rarity: :epic, xp_boost_percent: 12, gold_boost_percent: 10, price: 1500, level_required: 15, enchantment_slots: 3},
      %{name: "Ailes du Phoenix", description: "Renaissez de vos cendres avec une puissance inégalée.", icon: "🦅", rarity: :legendary, xp_boost_percent: 15, gold_boost_percent: 12, price: 3000, level_required: 20, enchantment_slots: 4},
      %{name: "Manteau de l'Infini", description: "Le cosmos entier dans un manteau.", icon: "🌌", rarity: :legendary, xp_boost_percent: 18, gold_boost_percent: 15, price: 5000, level_required: 25, enchantment_slots: 4},
      %{name: "Essence du Neant", description: "Le vide absolu. Le pouvoir ultime.", icon: "🕳️", rarity: :mythic, xp_boost_percent: 25, gold_boost_percent: 20, price: 10000, level_required: 40, enchantment_slots: 5},
      %{name: "Armure du Dragon Celeste", description: "Forgée dans le souffle d'un dragon celeste.", icon: "🐉", rarity: :mythic, xp_boost_percent: 30, gold_boost_percent: 25, price: 20000, level_required: 50, enchantment_slots: 5}
    ]

    Enum.each(skins, fn skin_attrs ->
      case Repo.get_by(Skin, name: skin_attrs.name) do
        nil -> %Skin{} |> Skin.changeset(skin_attrs) |> Repo.insert!()
        _existing -> :ok
      end
    end)
  end
end
