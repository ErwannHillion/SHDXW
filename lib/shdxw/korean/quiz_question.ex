defmodule Shdxw.Korean.QuizQuestion do
  use Ecto.Schema
  import Ecto.Changeset

  schema "korean_quiz_questions" do
    field :question, :string
    field :question_type, :string, default: "multiple_choice"
    field :correct_answer, :string
    field :options, {:array, :string}, default: []
    field :explanation, :string
    field :order, :integer, default: 0

    belongs_to :lesson, Shdxw.Korean.Lesson

    timestamps(type: :utc_datetime)
  end

  def changeset(question, attrs) do
    question
    |> cast(attrs, [:question, :question_type, :correct_answer, :options, :explanation, :order, :lesson_id])
    |> validate_required([:question, :correct_answer, :lesson_id])
  end
end
