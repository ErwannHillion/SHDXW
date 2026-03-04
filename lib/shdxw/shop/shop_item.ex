defmodule Shdxw.Shop.ShopItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "shop_items" do
    field :name, :string
    field :description, :string
    field :price, :integer
    field :type, Ecto.Enum, values: [:boost, :consumable, :cosmetic, :special]
    field :effect, :string
    field :duration_minutes, :integer
    field :icon, :string
    field :rarity, Ecto.Enum, values: [:common, :rare, :epic, :legendary], default: :common
    field :max_owned, :integer
    field :level_required, :integer, default: 1
    field :active, :boolean, default: true

    timestamps(type: :utc_datetime)
  end

  def changeset(item, attrs) do
    item
    |> cast(attrs, [
      :name,
      :description,
      :price,
      :type,
      :effect,
      :duration_minutes,
      :icon,
      :rarity,
      :max_owned,
      :level_required,
      :active
    ])
    |> validate_required([:name, :price, :type, :effect])
    |> validate_number(:price, greater_than: 0)
    |> validate_number(:level_required, greater_than_or_equal_to: 1)
  end
end
