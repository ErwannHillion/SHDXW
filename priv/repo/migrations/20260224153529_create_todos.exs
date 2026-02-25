defmodule Shdxw.Repo.Migrations.CreateTodos do
  use Ecto.Migration

  def change do
    create table(:todos) do
      add :title, :string, null: false
      add :description, :text
      add :status, :string, null: false, default: "pending"
      add :priority, :string, null: false, default: "medium"
      add :due_date, :date
      add :position, :integer, null: false, default: 0
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:todos, [:user_id])
    create index(:todos, [:user_id, :status])
    create index(:todos, [:user_id, :position])
  end
end
