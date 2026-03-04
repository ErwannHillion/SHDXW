defmodule Shdxw.Repo.Migrations.CreateUserItems do
  use Ecto.Migration

  def change do
    create table(:user_items) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :shop_item_id, references(:shop_items, on_delete: :delete_all), null: false
      add :quantity, :integer, null: false, default: 1
      add :active, :boolean, null: false, default: false
      add :activated_at, :utc_datetime
      add :expires_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create index(:user_items, [:user_id])
    create index(:user_items, [:user_id, :shop_item_id])
    create index(:user_items, [:user_id, :active])
  end
end
