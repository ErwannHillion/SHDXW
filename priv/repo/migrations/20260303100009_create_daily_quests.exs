defmodule Shdxw.Repo.Migrations.CreateDailyQuests do
  use Ecto.Migration

  def change do
    create table(:daily_quests) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :quest_type, :string, null: false
      add :description, :text, null: false
      add :target_value, :integer, null: false
      add :current_value, :integer, null: false, default: 0
      add :xp_reward, :integer, null: false
      add :gold_reward, :integer, null: false
      add :status, :string, null: false, default: "active"
      add :quest_date, :date, null: false
      add :completed_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create index(:daily_quests, [:user_id, :quest_date])
    create index(:daily_quests, [:user_id, :status])
  end
end
