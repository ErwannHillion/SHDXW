defmodule Shdxw.Repo.Migrations.CreateSkins do
  use Ecto.Migration

  def change do
    create table(:skins) do
      add :name, :string, null: false
      add :description, :text
      add :icon, :string, null: false
      add :rarity, :string, null: false, default: "common"
      add :xp_boost_percent, :integer, default: 0
      add :gold_boost_percent, :integer, default: 0
      add :price, :integer, null: false
      add :level_required, :integer, default: 1
      add :enchantment_slots, :integer, default: 1
      add :active, :boolean, default: true

      timestamps(type: :utc_datetime)
    end

    create table(:user_skins) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :skin_id, references(:skins, on_delete: :delete_all), null: false
      add :equipped, :boolean, default: false

      timestamps(type: :utc_datetime)
    end

    create index(:user_skins, [:user_id])
    create unique_index(:user_skins, [:user_id, :skin_id])
  end
end
