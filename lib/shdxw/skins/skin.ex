defmodule Shdxw.Skins.Skin do
  use Ecto.Schema
  import Ecto.Changeset

  schema "skins" do
    field :name, :string
    field :description, :string
    field :icon, :string
    field :rarity, Ecto.Enum, values: [:common, :rare, :epic, :legendary, :mythic], default: :common
    field :xp_boost_percent, :integer, default: 0
    field :gold_boost_percent, :integer, default: 0
    field :price, :integer
    field :level_required, :integer, default: 1
    field :enchantment_slots, :integer, default: 1
    field :active, :boolean, default: true

    timestamps(type: :utc_datetime)
  end

  def changeset(skin, attrs) do
    skin
    |> cast(attrs, [
      :name, :description, :icon, :rarity, :xp_boost_percent,
      :gold_boost_percent, :price, :level_required, :enchantment_slots, :active
    ])
    |> validate_required([:name, :icon, :price, :rarity])
    |> validate_number(:price, greater_than: 0)
    |> validate_number(:xp_boost_percent, greater_than_or_equal_to: 0)
    |> validate_number(:gold_boost_percent, greater_than_or_equal_to: 0)
    |> validate_number(:enchantment_slots, greater_than_or_equal_to: 0, less_than_or_equal_to: 5)
  end
end
