defmodule Shdxw.Repo.Migrations.CreateHabitCompletions do
  use Ecto.Migration

  def change do
    create table(:habit_completions) do
      add :habit_id, references(:habits, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :completed_date, :date, null: false
      add :count, :integer, null: false, default: 1

      timestamps(type: :utc_datetime)
    end

    create unique_index(:habit_completions, [:habit_id, :completed_date])
    create index(:habit_completions, [:user_id, :completed_date])
  end
end
