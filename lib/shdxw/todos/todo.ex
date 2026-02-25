defmodule Shdxw.Todos.Todo do
  use Ecto.Schema
  import Ecto.Changeset

  schema "todos" do
    field :title, :string
    field :description, :string
    field :status, Ecto.Enum, values: [:pending, :in_progress, :done], default: :pending
    field :priority, Ecto.Enum, values: [:low, :medium, :high, :urgent], default: :medium
    field :due_date, :date
    field :completed_at, :date
    field :position, :integer, default: 0

    belongs_to :user, Shdxw.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(todo, attrs) do
    todo
    |> cast(attrs, [:title, :description, :status, :priority, :due_date, :completed_at, :position])
    |> validate_required([:title])
    |> validate_length(:title, min: 1, max: 255)
    |> validate_length(:description, max: 2000)
  end

  def status_changeset(todo, attrs) do
    todo
    |> cast(attrs, [:status, :completed_at])
    |> validate_required([:status])
  end
end
