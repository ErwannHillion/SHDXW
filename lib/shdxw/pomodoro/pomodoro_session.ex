defmodule Shdxw.Pomodoro.PomodoroSession do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pomodoro_sessions" do
    field :duration_minutes, :integer, default: 25

    field :status, Ecto.Enum,
      values: [:in_progress, :completed, :cancelled],
      default: :in_progress

    field :started_at, :utc_datetime
    field :completed_at, :utc_datetime
    field :xp_earned, :integer, default: 0
    field :gold_earned, :integer, default: 0

    belongs_to :user, Shdxw.Accounts.User
    belongs_to :todo, Shdxw.Todos.Todo

    timestamps(type: :utc_datetime)
  end

  def changeset(session, attrs) do
    session
    |> cast(attrs, [
      :duration_minutes,
      :status,
      :started_at,
      :completed_at,
      :todo_id,
      :xp_earned,
      :gold_earned
    ])
    |> validate_required([:duration_minutes, :status, :started_at])
    |> validate_inclusion(:duration_minutes, [25, 45, 60])
  end
end
