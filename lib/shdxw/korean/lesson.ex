defmodule Shdxw.Korean.Lesson do
  use Ecto.Schema
  import Ecto.Changeset

  schema "korean_lessons" do
    field :day, :integer
    field :title, :string
    field :description, :string
    field :content, :string
    field :duration_minutes, :integer, default: 15
    field :xp_reward, :integer, default: 30
    field :gold_reward, :integer, default: 15
    field :order, :integer

    has_many :quiz_questions, Shdxw.Korean.QuizQuestion

    timestamps(type: :utc_datetime)
  end

  def changeset(lesson, attrs) do
    lesson
    |> cast(attrs, [:day, :title, :description, :content, :duration_minutes, :xp_reward, :gold_reward, :order])
    |> validate_required([:day, :title, :content, :order])
    |> unique_constraint(:day)
  end
end
