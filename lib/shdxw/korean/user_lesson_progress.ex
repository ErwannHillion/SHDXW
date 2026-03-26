defmodule Shdxw.Korean.UserLessonProgress do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_lesson_progress" do
    field :completed, :boolean, default: false
    field :quiz_score, :integer
    field :quiz_total, :integer
    field :completed_at, :utc_datetime
    field :best_score, :integer, default: 0

    belongs_to :user, Shdxw.Accounts.User
    belongs_to :lesson, Shdxw.Korean.Lesson

    timestamps(type: :utc_datetime)
  end

  def changeset(progress, attrs) do
    progress
    |> cast(attrs, [:completed, :quiz_score, :quiz_total, :completed_at, :best_score, :user_id, :lesson_id])
    |> validate_required([:user_id, :lesson_id])
    |> unique_constraint([:user_id, :lesson_id])
  end
end
