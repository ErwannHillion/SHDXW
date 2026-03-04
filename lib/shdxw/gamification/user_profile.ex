defmodule Shdxw.Gamification.UserProfile do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_profiles" do
    field :xp, :integer, default: 0
    field :level, :integer, default: 1
    field :gold, :integer, default: 0
    field :total_gold_earned, :integer, default: 0
    field :current_streak, :integer, default: 0
    field :longest_streak, :integer, default: 0
    field :last_active_date, :date
    field :total_todos_completed, :integer, default: 0
    field :total_pomodoros_completed, :integer, default: 0
    field :total_habits_completed, :integer, default: 0
    field :title, :string, default: "Novice"

    belongs_to :user, Shdxw.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(profile, attrs) do
    profile
    |> cast(attrs, [
      :xp,
      :level,
      :gold,
      :total_gold_earned,
      :current_streak,
      :longest_streak,
      :last_active_date,
      :total_todos_completed,
      :total_pomodoros_completed,
      :total_habits_completed,
      :title
    ])
  end
end
