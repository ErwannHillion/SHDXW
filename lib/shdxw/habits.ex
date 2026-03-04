defmodule Shdxw.Habits do
  @moduledoc """
  The Habits context. Manages recurring habits with streak tracking.
  """

  import Ecto.Query, warn: false
  alias Shdxw.Repo
  alias Shdxw.Accounts.Scope
  alias Shdxw.Habits.{Habit, HabitCompletion}

  @topic_prefix "habits"

  defp topic(%Scope{user: user}), do: "#{@topic_prefix}:#{user.id}"

  def subscribe(%Scope{} = scope) do
    Phoenix.PubSub.subscribe(Shdxw.PubSub, topic(scope))
  end

  defp broadcast(%Scope{} = scope, event, payload) do
    Phoenix.PubSub.broadcast(Shdxw.PubSub, topic(scope), {event, payload})
  end

  def list_habits(%Scope{} = scope) do
    Habit
    |> where(user_id: ^scope.user.id, active: true)
    |> order_by(asc: :position, asc: :inserted_at)
    |> Repo.all()
  end

  def list_habits_with_today_status(%Scope{} = scope) do
    today = Date.utc_today()
    habits = list_habits(scope)

    habit_ids = Enum.map(habits, & &1.id)

    completions_today =
      HabitCompletion
      |> where([c], c.habit_id in ^habit_ids and c.completed_date == ^today)
      |> select([c], c.habit_id)
      |> Repo.all()
      |> MapSet.new()

    Enum.map(habits, fn habit ->
      {habit, MapSet.member?(completions_today, habit.id)}
    end)
  end

  def get_habit!(%Scope{} = scope, id) do
    Repo.get_by!(Habit, id: id, user_id: scope.user.id)
  end

  def create_habit(%Scope{} = scope, attrs) do
    next_position =
      Habit
      |> where(user_id: ^scope.user.id)
      |> select([h], coalesce(max(h.position), -1) + 1)
      |> Repo.one()

    %Habit{user_id: scope.user.id, position: next_position}
    |> Habit.changeset(attrs)
    |> Repo.insert()
    |> tap_ok(fn habit -> broadcast(scope, :habit_created, habit) end)
  end

  def update_habit(%Scope{} = scope, %Habit{} = habit, attrs) do
    true = habit.user_id == scope.user.id

    habit
    |> Habit.changeset(attrs)
    |> Repo.update()
    |> tap_ok(fn habit -> broadcast(scope, :habit_updated, habit) end)
  end

  def delete_habit(%Scope{} = scope, %Habit{} = habit) do
    true = habit.user_id == scope.user.id

    Repo.delete(habit)
    |> tap_ok(fn habit -> broadcast(scope, :habit_deleted, habit) end)
  end

  def complete_habit(%Scope{} = scope, %Habit{} = habit) do
    today = Date.utc_today()

    # Check if already completed today
    existing =
      Repo.get_by(HabitCompletion, habit_id: habit.id, completed_date: today)

    if existing do
      {:ok, existing}
    else
      result =
        %HabitCompletion{habit_id: habit.id, user_id: scope.user.id}
        |> HabitCompletion.changeset(%{completed_date: today})
        |> Repo.insert()

      case result do
        {:ok, completion} ->
          # Update streak
          update_habit_streak(habit)

          # Update gamification profile counter
          profile = Shdxw.Gamification.get_or_create_profile(scope)

          profile
          |> Shdxw.Gamification.UserProfile.changeset(%{
            total_habits_completed: profile.total_habits_completed + 1
          })
          |> Repo.update()

          # Award XP
          {xp, gold} =
            case habit.frequency do
              :daily -> {habit.xp_reward, 8}
              :weekly -> {habit.xp_reward + 10, 15}
            end

          Shdxw.Gamification.award_xp_and_gold(
            scope,
            "habit",
            habit.id,
            xp,
            gold,
            "Habitude: #{habit.name}"
          )

          # Update daily quest progress
          Shdxw.DailyQuests.update_quest_progress(scope, "complete_habits")

          # Check achievements
          Shdxw.Achievements.check_and_award(scope, :habits)

          broadcast(scope, :habit_completed, %{habit: habit, completion: completion})
          {:ok, completion}

        error ->
          error
      end
    end
  end

  def uncomplete_habit(%Scope{} = scope, %Habit{} = habit) do
    today = Date.utc_today()

    case Repo.get_by(HabitCompletion, habit_id: habit.id, completed_date: today) do
      nil ->
        {:ok, nil}

      completion ->
        Repo.delete(completion)
        broadcast(scope, :habit_uncompleted, %{habit: habit})
        {:ok, nil}
    end
  end

  defp update_habit_streak(%Habit{} = habit) do
    today = Date.utc_today()
    yesterday = Date.add(today, -1)

    had_yesterday =
      Repo.exists?(
        from(c in HabitCompletion,
          where: c.habit_id == ^habit.id and c.completed_date == ^yesterday
        )
      )

    new_streak = if had_yesterday, do: habit.current_streak + 1, else: 1
    longest = max(new_streak, habit.longest_streak)

    habit
    |> Habit.changeset(%{current_streak: new_streak, longest_streak: longest})
    |> Repo.update()
  end

  def get_weekly_heatmap(%Scope{} = scope) do
    today = Date.utc_today()
    week_ago = Date.add(today, -6)

    completions =
      from(c in HabitCompletion,
        where: c.user_id == ^scope.user.id,
        where: c.completed_date >= ^week_ago and c.completed_date <= ^today,
        group_by: c.completed_date,
        select: {c.completed_date, count(c.id)}
      )
      |> Repo.all()
      |> Map.new()

    Enum.map(0..6, fn offset ->
      date = Date.add(week_ago, offset)
      count = Map.get(completions, date, 0)
      {date, count}
    end)
  end

  def change_habit(%Habit{} = habit, attrs \\ %{}) do
    Habit.changeset(habit, attrs)
  end

  defp tap_ok({:ok, record} = result, fun) do
    fun.(record)
    result
  end

  defp tap_ok(error, _fun), do: error
end
