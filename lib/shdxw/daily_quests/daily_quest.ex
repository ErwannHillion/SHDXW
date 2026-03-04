defmodule Shdxw.DailyQuests.DailyQuest do
  use Ecto.Schema
  import Ecto.Changeset

  schema "daily_quests" do
    field :quest_type, :string
    field :description, :string
    field :target_value, :integer
    field :current_value, :integer, default: 0
    field :xp_reward, :integer
    field :gold_reward, :integer
    field :status, Ecto.Enum, values: [:active, :completed, :expired], default: :active
    field :quest_date, :date
    field :completed_at, :utc_datetime

    belongs_to :user, Shdxw.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(quest, attrs) do
    quest
    |> cast(attrs, [
      :quest_type,
      :description,
      :target_value,
      :current_value,
      :xp_reward,
      :gold_reward,
      :status,
      :quest_date,
      :completed_at,
      :user_id
    ])
    |> validate_required([
      :quest_type,
      :description,
      :target_value,
      :xp_reward,
      :gold_reward,
      :quest_date,
      :user_id
    ])
  end
end
