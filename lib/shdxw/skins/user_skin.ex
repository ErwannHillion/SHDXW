defmodule Shdxw.Skins.UserSkin do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_skins" do
    field :equipped, :boolean, default: false

    belongs_to :user, Shdxw.Accounts.User
    belongs_to :skin, Shdxw.Skins.Skin

    timestamps(type: :utc_datetime)
  end

  def changeset(user_skin, attrs) do
    user_skin
    |> cast(attrs, [:skin_id, :user_id, :equipped])
    |> validate_required([:skin_id, :user_id])
    |> unique_constraint([:user_id, :skin_id])
  end
end
