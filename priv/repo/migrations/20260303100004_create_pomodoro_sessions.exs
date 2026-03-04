defmodule Shdxw.Repo.Migrations.CreatePomodoroSessions do
  use Ecto.Migration

  def change do
    create table(:pomodoro_sessions) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :duration_minutes, :integer, null: false, default: 25
      add :status, :string, null: false, default: "in_progress"
      add :started_at, :utc_datetime, null: false
      add :completed_at, :utc_datetime
      add :todo_id, references(:todos, on_delete: :nilify_all)
      add :xp_earned, :integer, null: false, default: 0
      add :gold_earned, :integer, null: false, default: 0

      timestamps(type: :utc_datetime)
    end

    create index(:pomodoro_sessions, [:user_id])
    create index(:pomodoro_sessions, [:user_id, :status])
  end
end
