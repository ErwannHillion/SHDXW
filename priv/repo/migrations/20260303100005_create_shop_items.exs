defmodule Shdxw.Repo.Migrations.CreateShopItems do
  use Ecto.Migration

  def change do
    create table(:shop_items) do
      add :name, :string, null: false
      add :description, :text
      add :price, :integer, null: false
      add :type, :string, null: false
      add :effect, :string, null: false
      add :duration_minutes, :integer
      add :icon, :string
      add :rarity, :string, null: false, default: "common"
      add :max_owned, :integer
      add :level_required, :integer, null: false, default: 1
      add :active, :boolean, null: false, default: true

      timestamps(type: :utc_datetime)
    end
  end
end
