defmodule Shdxw.Shop.UserItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_items" do
    field :quantity, :integer, default: 1
    field :active, :boolean, default: false
    field :activated_at, :utc_datetime
    field :expires_at, :utc_datetime

    belongs_to :user, Shdxw.Accounts.User
    belongs_to :shop_item, Shdxw.Shop.ShopItem

    timestamps(type: :utc_datetime)
  end

  def changeset(user_item, attrs) do
    user_item
    |> cast(attrs, [:quantity, :active, :activated_at, :expires_at, :shop_item_id, :user_id])
    |> validate_required([:shop_item_id, :user_id])
    |> validate_number(:quantity, greater_than: 0)
  end
end
