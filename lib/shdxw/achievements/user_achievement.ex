defmodule Shdxw.Achievements.UserAchievement do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_achievements" do
    field :unlocked_at, :utc_datetime

    belongs_to :user, Shdxw.Accounts.User
    belongs_to :achievement, Shdxw.Achievements.Achievement

    timestamps(type: :utc_datetime)
  end

  def changeset(user_achievement, attrs) do
    user_achievement
    |> cast(attrs, [:unlocked_at, :achievement_id, :user_id])
    |> validate_required([:unlocked_at, :achievement_id, :user_id])
    |> unique_constraint([:user_id, :achievement_id])
  end
end
