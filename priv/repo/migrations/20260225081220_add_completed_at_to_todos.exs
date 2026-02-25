defmodule Shdxw.Repo.Migrations.AddCompletedAtToTodos do
  use Ecto.Migration

  def change do
    alter table(:todos) do
      add :completed_at, :date
    end

    create index(:todos, [:user_id, :completed_at])
  end
end
