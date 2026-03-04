defmodule Shdxw.Achievements.Achievement do
  use Ecto.Schema
  import Ecto.Changeset

  schema "achievements" do
    field :key, :string
    field :name, :string
    field :description, :string
    field :icon, :string

    field :category, Ecto.Enum,
      values: [:todos, :habits, :pomodoro, :streak, :level, :shop, :secret]

    field :rarity, Ecto.Enum, values: [:common, :rare, :epic, :legendary], default: :common
    field :xp_reward, :integer, default: 0
    field :gold_reward, :integer, default: 0
    field :condition_type, :string
    field :condition_value, :integer
    field :hidden, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  def changeset(achievement, attrs) do
    achievement
    |> cast(attrs, [
      :key,
      :name,
      :description,
      :icon,
      :category,
      :rarity,
      :xp_reward,
      :gold_reward,
      :condition_type,
      :condition_value,
      :hidden
    ])
    |> validate_required([:key, :name, :category, :condition_type, :condition_value])
    |> unique_constraint(:key)
  end
end
