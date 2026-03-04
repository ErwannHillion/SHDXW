defmodule Shdxw.Habits.Habit do
  use Ecto.Schema
  import Ecto.Changeset

  schema "habits" do
    field :name, :string
    field :description, :string
    field :icon, :string, default: "hero-star"
    field :color, :string, default: "purple"
    field :frequency, Ecto.Enum, values: [:daily, :weekly], default: :daily
    field :target_count, :integer, default: 1
    field :current_streak, :integer, default: 0
    field :longest_streak, :integer, default: 0
    field :xp_reward, :integer, default: 15
    field :active, :boolean, default: true
    field :position, :integer, default: 0

    belongs_to :user, Shdxw.Accounts.User
    has_many :completions, Shdxw.Habits.HabitCompletion

    timestamps(type: :utc_datetime)
  end

  def changeset(habit, attrs) do
    habit
    |> cast(attrs, [
      :name,
      :description,
      :icon,
      :color,
      :frequency,
      :target_count,
      :xp_reward,
      :active,
      :position
    ])
    |> validate_required([:name])
    |> validate_length(:name, min: 1, max: 100)
    |> validate_length(:description, max: 500)
    |> validate_number(:target_count, greater_than: 0)
    |> validate_number(:xp_reward, greater_than_or_equal_to: 0)
  end
end
