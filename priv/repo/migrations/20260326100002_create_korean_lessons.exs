defmodule Shdxw.Repo.Migrations.CreateKoreanLessons do
  use Ecto.Migration

  def change do
    create table(:korean_lessons) do
      add :day, :integer, null: false
      add :title, :string, null: false
      add :description, :text
      add :content, :text, null: false
      add :duration_minutes, :integer, default: 15
      add :xp_reward, :integer, default: 30
      add :gold_reward, :integer, default: 15
      add :order, :integer, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:korean_lessons, [:day])

    create table(:korean_quiz_questions) do
      add :lesson_id, references(:korean_lessons, on_delete: :delete_all), null: false
      add :question, :string, null: false
      add :question_type, :string, null: false, default: "multiple_choice"
      add :correct_answer, :string, null: false
      add :options, {:array, :string}, default: []
      add :explanation, :text
      add :order, :integer, default: 0

      timestamps(type: :utc_datetime)
    end

    create index(:korean_quiz_questions, [:lesson_id])

    create table(:user_lesson_progress) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :lesson_id, references(:korean_lessons, on_delete: :delete_all), null: false
      add :completed, :boolean, default: false
      add :quiz_score, :integer
      add :quiz_total, :integer
      add :completed_at, :utc_datetime
      add :best_score, :integer, default: 0

      timestamps(type: :utc_datetime)
    end

    create unique_index(:user_lesson_progress, [:user_id, :lesson_id])
    create index(:user_lesson_progress, [:user_id])
  end
end
