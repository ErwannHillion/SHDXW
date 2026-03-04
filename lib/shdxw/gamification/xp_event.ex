defmodule Shdxw.Gamification.XpEvent do
  use Ecto.Schema
  import Ecto.Changeset

  schema "xp_events" do
    field :source, :string
    field :source_id, :integer
    field :xp_amount, :integer, default: 0
    field :gold_amount, :integer, default: 0
    field :description, :string

    belongs_to :user, Shdxw.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(event, attrs) do
    event
    |> cast(attrs, [:source, :source_id, :xp_amount, :gold_amount, :description, :user_id])
    |> validate_required([:source, :user_id])
  end
end
