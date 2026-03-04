defmodule Shdxw.Habits.HabitCompletion do
  use Ecto.Schema
  import Ecto.Changeset

  schema "habit_completions" do
    field :completed_date, :date
    field :count, :integer, default: 1

    belongs_to :habit, Shdxw.Habits.Habit
    belongs_to :user, Shdxw.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(completion, attrs) do
    completion
    |> cast(attrs, [:completed_date, :count, :habit_id, :user_id])
    |> validate_required([:completed_date, :habit_id, :user_id])
    |> unique_constraint([:habit_id, :completed_date])
  end
end
