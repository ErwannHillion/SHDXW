defmodule Shdxw.Enchantments.Enchantment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "enchantments" do
    field :name, :string
    field :description, :string
    field :icon, :string
    field :type, Ecto.Enum,
      values: [:fortune, :experience, :sharpness, :efficiency, :looting, :protection, :mending, :thorns, :fire_aspect, :luck_of_the_sea]
    field :max_level, :integer, default: 5
    field :base_effect_value, :integer, default: 0
    field :effect_per_level, :integer, default: 0
    field :base_cost, :integer, default: 100
    field :cost_multiplier, :float, default: 1.5
    field :min_player_level, :integer, default: 1
    field :rarity, Ecto.Enum, values: [:common, :rare, :epic, :legendary], default: :common
    field :compatible_rarities, {:array, :string}, default: ["common", "rare", "epic", "legendary", "mythic"]

    timestamps(type: :utc_datetime)
  end

  def changeset(enchantment, attrs) do
    enchantment
    |> cast(attrs, [
      :name, :description, :icon, :type, :max_level,
      :base_effect_value, :effect_per_level, :base_cost,
      :cost_multiplier, :min_player_level, :rarity, :compatible_rarities
    ])
    |> validate_required([:name, :icon, :type, :rarity])
    |> validate_number(:max_level, greater_than: 0, less_than_or_equal_to: 10)
    |> unique_constraint(:name)
  end

  def cost_for_level(%__MODULE__{} = enchantment, level) do
    round(enchantment.base_cost * :math.pow(enchantment.cost_multiplier, level - 1))
  end

  def effect_at_level(%__MODULE__{} = enchantment, level) do
    enchantment.base_effect_value + enchantment.effect_per_level * level
  end
end
