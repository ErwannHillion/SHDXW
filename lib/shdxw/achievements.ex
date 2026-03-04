defmodule Shdxw.Achievements do
  @moduledoc """
  The Achievements context. Manages unlockable achievements and badges.
  """

  import Ecto.Query, warn: false
  alias Shdxw.Repo
  alias Shdxw.Accounts.Scope
  alias Shdxw.Achievements.{Achievement, UserAchievement}

  @topic_prefix "achievements"

  defp topic(%Scope{user: user}), do: "#{@topic_prefix}:#{user.id}"

  def subscribe(%Scope{} = scope) do
    Phoenix.PubSub.subscribe(Shdxw.PubSub, topic(scope))
  end

  defp broadcast(%Scope{} = scope, event, payload) do
    Phoenix.PubSub.broadcast(Shdxw.PubSub, topic(scope), {event, payload})
  end

  def list_all_achievements do
    Achievement
    |> order_by(asc: :category, asc: :condition_value)
    |> Repo.all()
  end

  def list_user_achievements(%Scope{} = scope) do
    from(ua in UserAchievement,
      where: ua.user_id == ^scope.user.id,
      join: a in Achievement,
      on: ua.achievement_id == a.id,
      preload: [achievement: a],
      order_by: [desc: ua.unlocked_at]
    )
    |> Repo.all()
  end

  def unlocked_achievement_ids(%Scope{} = scope) do
    from(ua in UserAchievement,
      where: ua.user_id == ^scope.user.id,
      select: ua.achievement_id
    )
    |> Repo.all()
    |> MapSet.new()
  end

  def check_and_award(%Scope{} = scope, category) do
    profile = Shdxw.Gamification.get_or_create_profile(scope)
    unlocked_ids = unlocked_achievement_ids(scope)

    achievements =
      Achievement
      |> where(category: ^category)
      |> Repo.all()

    newly_unlocked =
      Enum.filter(achievements, fn achievement ->
        not MapSet.member?(unlocked_ids, achievement.id) and
          condition_met?(achievement, profile, scope)
      end)

    Enum.each(newly_unlocked, fn achievement ->
      unlock_achievement(scope, achievement)
    end)

    newly_unlocked
  end

  defp condition_met?(
         %Achievement{condition_type: "count", condition_value: value, category: :todos},
         profile,
         _scope
       ) do
    profile.total_todos_completed >= value
  end

  defp condition_met?(
         %Achievement{condition_type: "count", condition_value: value, category: :habits},
         profile,
         _scope
       ) do
    profile.total_habits_completed >= value
  end

  defp condition_met?(
         %Achievement{condition_type: "count", condition_value: value, category: :pomodoro},
         profile,
         _scope
       ) do
    profile.total_pomodoros_completed >= value
  end

  defp condition_met?(
         %Achievement{condition_type: "streak", condition_value: value, category: :streak},
         profile,
         _scope
       ) do
    profile.current_streak >= value or profile.longest_streak >= value
  end

  defp condition_met?(
         %Achievement{condition_type: "level", condition_value: value, category: :level},
         profile,
         _scope
       ) do
    profile.level >= value
  end

  defp condition_met?(
         %Achievement{condition_type: "count", condition_value: value, category: :shop},
         profile,
         _scope
       ) do
    profile.total_gold_earned >= value
  end

  defp condition_met?(
         %Achievement{condition_type: "purchase", condition_value: value},
         _profile,
         scope
       ) do
    count =
      from(ui in Shdxw.Shop.UserItem,
        where: ui.user_id == ^scope.user.id,
        select: count(ui.id)
      )
      |> Repo.one()

    count >= value
  end

  defp condition_met?(_achievement, _profile, _scope), do: false

  def unlock_achievement(%Scope{} = scope, %Achievement{} = achievement) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    case %UserAchievement{user_id: scope.user.id}
         |> UserAchievement.changeset(%{achievement_id: achievement.id, unlocked_at: now})
         |> Repo.insert(on_conflict: :nothing) do
      {:ok, user_achievement} ->
        # Award XP and gold from the achievement
        if achievement.xp_reward > 0 or achievement.gold_reward > 0 do
          Shdxw.Gamification.award_xp_and_gold(
            scope,
            "achievement",
            achievement.id,
            achievement.xp_reward,
            achievement.gold_reward,
            "Achievement: #{achievement.name}"
          )
        end

        broadcast(scope, :achievement_unlocked, %{
          achievement: achievement,
          user_achievement: user_achievement
        })

        {:ok, user_achievement}

      error ->
        error
    end
  end

  def get_progress(%Scope{} = scope, %Achievement{} = achievement) do
    profile = Shdxw.Gamification.get_or_create_profile(scope)

    current =
      case {achievement.category, achievement.condition_type} do
        {:todos, "count"} -> profile.total_todos_completed
        {:habits, "count"} -> profile.total_habits_completed
        {:pomodoro, "count"} -> profile.total_pomodoros_completed
        {:streak, "streak"} -> max(profile.current_streak, profile.longest_streak)
        {:level, "level"} -> profile.level
        {:shop, "count"} -> profile.total_gold_earned
        _ -> 0
      end

    {min(current, achievement.condition_value), achievement.condition_value}
  end

  def count_unlocked(%Scope{} = scope) do
    from(ua in UserAchievement,
      where: ua.user_id == ^scope.user.id,
      select: count(ua.id)
    )
    |> Repo.one()
  end
end
