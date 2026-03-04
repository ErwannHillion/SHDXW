defmodule Shdxw.Repo.Migrations.CreateHabits do
  use Ecto.Migration

  def change do
    create table(:habits) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :name, :string, null: false
      add :description, :text
      add :icon, :string, default: "hero-star"
      add :color, :string, default: "purple"
      add :frequency, :string, null: false, default: "daily"
      add :target_count, :integer, null: false, default: 1
      add :current_streak, :integer, null: false, default: 0
      add :longest_streak, :integer, null: false, default: 0
      add :xp_reward, :integer, null: false, default: 15
      add :active, :boolean, null: false, default: true
      add :position, :integer, null: false, default: 0

      timestamps(type: :utc_datetime)
    end

    create index(:habits, [:user_id])
    create index(:habits, [:user_id, :active])
  end
end
