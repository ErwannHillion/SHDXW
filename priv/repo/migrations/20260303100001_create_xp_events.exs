defmodule Shdxw.Repo.Migrations.CreateXpEvents do
  use Ecto.Migration

  def change do
    create table(:xp_events) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :source, :string, null: false
      add :source_id, :integer
      add :xp_amount, :integer, null: false, default: 0
      add :gold_amount, :integer, null: false, default: 0
      add :description, :string

      timestamps(type: :utc_datetime)
    end

    create index(:xp_events, [:user_id])
  end
end
