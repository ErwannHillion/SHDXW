defmodule Shdxw.Repo.Migrations.CreateUserProfiles do
  use Ecto.Migration

  def change do
    create table(:user_profiles) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :xp, :integer, null: false, default: 0
      add :level, :integer, null: false, default: 1
      add :gold, :integer, null: false, default: 0
      add :total_gold_earned, :integer, null: false, default: 0
      add :current_streak, :integer, null: false, default: 0
      add :longest_streak, :integer, null: false, default: 0
      add :last_active_date, :date
      add :total_todos_completed, :integer, null: false, default: 0
      add :total_pomodoros_completed, :integer, null: false, default: 0
      add :total_habits_completed, :integer, null: false, default: 0
      add :title, :string, default: "Novice"

      timestamps(type: :utc_datetime)
    end

    create unique_index(:user_profiles, [:user_id])
  end
end
