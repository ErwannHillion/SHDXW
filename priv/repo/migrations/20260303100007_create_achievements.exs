defmodule Shdxw.Repo.Migrations.CreateAchievements do
  use Ecto.Migration

  def change do
    create table(:achievements) do
      add :key, :string, null: false
      add :name, :string, null: false
      add :description, :text
      add :icon, :string
      add :category, :string, null: false
      add :rarity, :string, null: false, default: "common"
      add :xp_reward, :integer, null: false, default: 0
      add :gold_reward, :integer, null: false, default: 0
      add :condition_type, :string, null: false
      add :condition_value, :integer, null: false
      add :hidden, :boolean, null: false, default: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:achievements, [:key])
  end
end
