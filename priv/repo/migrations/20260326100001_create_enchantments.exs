defmodule Shdxw.Repo.Migrations.CreateEnchantments do
  use Ecto.Migration

  def change do
    create table(:enchantments) do
      add :name, :string, null: false
      add :description, :text
      add :icon, :string, null: false
      add :type, :string, null: false
      add :max_level, :integer, default: 5
      add :base_effect_value, :integer, default: 0
      add :effect_per_level, :integer, default: 0
      add :base_cost, :integer, default: 100
      add :cost_multiplier, :float, default: 1.5
      add :min_player_level, :integer, default: 1
      add :rarity, :string, null: false, default: "common"
      add :compatible_rarities, {:array, :string}, default: ["common", "rare", "epic", "legendary", "mythic"]

      timestamps(type: :utc_datetime)
    end

    create unique_index(:enchantments, [:name])

    create table(:skin_enchantments) do
      add :user_skin_id, references(:user_skins, on_delete: :delete_all), null: false
      add :enchantment_id, references(:enchantments, on_delete: :delete_all), null: false
      add :level, :integer, default: 1
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:skin_enchantments, [:user_skin_id])
    create index(:skin_enchantments, [:user_id])
    create unique_index(:skin_enchantments, [:user_skin_id, :enchantment_id])
  end
end
