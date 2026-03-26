defmodule Shdxw.Korean do
  @moduledoc """
  The Korean context. Manages Korean language lessons, quizzes, and user progress.
  """

  import Ecto.Query, warn: false
  alias Shdxw.Repo
  alias Shdxw.Accounts.Scope
  alias Shdxw.Korean.{Lesson, QuizQuestion, UserLessonProgress}

  # --- Lessons ---

  def list_lessons do
    Lesson
    |> order_by(asc: :order)
    |> Repo.all()
  end

  def get_lesson!(id), do: Repo.get!(Lesson, id)

  def get_lesson_by_day!(day) do
    Repo.get_by!(Lesson, day: day)
  end

  def get_lesson_with_questions!(id) do
    Lesson
    |> Repo.get!(id)
    |> Repo.preload(quiz_questions: from(q in QuizQuestion, order_by: q.order))
  end

  # --- Quiz ---

  def list_quiz_questions(lesson_id) do
    QuizQuestion
    |> where(lesson_id: ^lesson_id)
    |> order_by(asc: :order)
    |> Repo.all()
  end

  # --- Progress ---

  def get_user_progress(%Scope{} = scope) do
    from(p in UserLessonProgress,
      where: p.user_id == ^scope.user.id,
      join: l in Lesson,
      on: p.lesson_id == l.id,
      preload: [lesson: l],
      order_by: [asc: l.order]
    )
    |> Repo.all()
  end

  def get_lesson_progress(%Scope{} = scope, lesson_id) do
    Repo.get_by(UserLessonProgress,
      user_id: scope.user.id,
      lesson_id: lesson_id
    )
  end

  def complete_lesson(%Scope{} = scope, lesson_id, quiz_score, quiz_total) do
    lesson = get_lesson!(lesson_id)
    existing = get_lesson_progress(scope, lesson_id)
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    best = if existing, do: max(existing.best_score, quiz_score), else: quiz_score

    case existing do
      nil ->
        {:ok, progress} =
          %UserLessonProgress{user_id: scope.user.id}
          |> UserLessonProgress.changeset(%{
            lesson_id: lesson_id,
            completed: true,
            quiz_score: quiz_score,
            quiz_total: quiz_total,
            completed_at: now,
            best_score: best
          })
          |> Repo.insert()

        # Award XP on first completion
        score_ratio = if quiz_total > 0, do: quiz_score / quiz_total, else: 0
        bonus_xp = round(lesson.xp_reward * score_ratio)
        bonus_gold = round(lesson.gold_reward * score_ratio)

        Shdxw.Gamification.award_xp_and_gold(
          scope,
          "korean",
          lesson_id,
          bonus_xp,
          bonus_gold,
          "Lecon coreen: #{lesson.title} (#{quiz_score}/#{quiz_total})"
        )

        {:ok, progress}

      progress ->
        {:ok, updated} =
          progress
          |> UserLessonProgress.changeset(%{
            quiz_score: quiz_score,
            quiz_total: quiz_total,
            completed_at: now,
            best_score: best
          })
          |> Repo.update()

        # Award smaller XP for retakes if improved
        if quiz_score > progress.quiz_score do
          improvement = quiz_score - progress.quiz_score
          Shdxw.Gamification.award_xp_and_gold(
            scope,
            "korean",
            lesson_id,
            improvement * 5,
            improvement * 2,
            "Amelioration lecon: #{lesson.title}"
          )
        end

        {:ok, updated}
    end
  end

  def lessons_completed_count(%Scope{} = scope) do
    from(p in UserLessonProgress,
      where: p.user_id == ^scope.user.id and p.completed == true
    )
    |> Repo.aggregate(:count)
  end

  def is_lesson_unlocked?(%Scope{} = scope, lesson) do
    if lesson.day == 1 do
      true
    else
      # Previous lesson must be completed
      prev_lesson = Repo.get_by(Lesson, day: lesson.day - 1)

      if prev_lesson do
        case get_lesson_progress(scope, prev_lesson.id) do
          %{completed: true} -> true
          _ -> false
        end
      else
        true
      end
    end
  end

  def get_overall_stats(%Scope{} = scope) do
    total_lessons = Repo.aggregate(Lesson, :count)
    completed = lessons_completed_count(scope)

    avg_score =
      from(p in UserLessonProgress,
        where: p.user_id == ^scope.user.id and p.completed == true,
        select: avg(p.best_score * 100.0 / p.quiz_total)
      )
      |> Repo.one() || 0

    %{
      total: total_lessons,
      completed: completed,
      avg_score: round(avg_score),
      percent: if(total_lessons > 0, do: round(completed / total_lessons * 100), else: 0)
    }
  end
end
