defmodule Shdxw.Enchantments.SkinEnchantment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "skin_enchantments" do
    field :level, :integer, default: 1

    belongs_to :user_skin, Shdxw.Skins.UserSkin
    belongs_to :enchantment, Shdxw.Enchantments.Enchantment
    belongs_to :user, Shdxw.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(skin_enchantment, attrs) do
    skin_enchantment
    |> cast(attrs, [:user_skin_id, :enchantment_id, :user_id, :level])
    |> validate_required([:user_skin_id, :enchantment_id, :user_id])
    |> validate_number(:level, greater_than: 0)
    |> unique_constraint([:user_skin_id, :enchantment_id])
  end
end
