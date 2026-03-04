defmodule Shdxw.Pomodoro do
  @moduledoc """
  The Pomodoro context. Manages focus timer sessions with gamification.
  """

  import Ecto.Query, warn: false
  alias Shdxw.Repo
  alias Shdxw.Accounts.Scope
  alias Shdxw.Pomodoro.PomodoroSession

  @topic_prefix "pomodoro"

  @xp_table %{
    25 => {30, 15},
    45 => {55, 30},
    60 => {70, 40}
  }

  defp topic(%Scope{user: user}), do: "#{@topic_prefix}:#{user.id}"

  def subscribe(%Scope{} = scope) do
    Phoenix.PubSub.subscribe(Shdxw.PubSub, topic(scope))
  end

  defp broadcast(%Scope{} = scope, event, payload) do
    Phoenix.PubSub.broadcast(Shdxw.PubSub, topic(scope), {event, payload})
  end

  def start_session(%Scope{} = scope, attrs \\ %{}) do
    # Cancel any existing in_progress session
    cancel_active_sessions(scope)

    duration = Map.get(attrs, :duration_minutes, 25)
    todo_id = Map.get(attrs, :todo_id)

    %PomodoroSession{user_id: scope.user.id}
    |> PomodoroSession.changeset(%{
      duration_minutes: duration,
      started_at: DateTime.utc_now() |> DateTime.truncate(:second),
      status: :in_progress,
      todo_id: todo_id
    })
    |> Repo.insert()
    |> tap_ok(fn session -> broadcast(scope, :pomodoro_started, session) end)
  end

  def complete_session(%Scope{} = scope, %PomodoroSession{} = session) do
    # Anti-cheat: verify enough time elapsed (allow 5s tolerance)
    elapsed = DateTime.diff(DateTime.utc_now(), session.started_at, :second)
    required = session.duration_minutes * 60 - 5

    if elapsed >= required and session.status == :in_progress do
      {xp, gold} = Map.get(@xp_table, session.duration_minutes, {30, 15})

      {:ok, updated} =
        session
        |> PomodoroSession.changeset(%{
          status: :completed,
          completed_at: DateTime.utc_now() |> DateTime.truncate(:second),
          xp_earned: xp,
          gold_earned: gold
        })
        |> Repo.update()

      # Award XP and gold
      Shdxw.Gamification.award_xp_and_gold(
        scope,
        "pomodoro",
        session.id,
        xp,
        gold,
        "Pomodoro #{session.duration_minutes}min termine"
      )

      # Update profile counter
      profile = Shdxw.Gamification.get_or_create_profile(scope)

      profile
      |> Shdxw.Gamification.UserProfile.changeset(%{
        total_pomodoros_completed: profile.total_pomodoros_completed + 1
      })
      |> Repo.update()

      # Update daily quest progress
      Shdxw.DailyQuests.update_quest_progress(scope, "pomodoro_session")

      # Check achievements
      Shdxw.Achievements.check_and_award(scope, :pomodoro)

      broadcast(scope, :pomodoro_completed, updated)
      {:ok, updated}
    else
      {:error, :session_not_valid}
    end
  end

  def cancel_session(%Scope{} = scope, %PomodoroSession{} = session) do
    if session.status == :in_progress do
      {:ok, updated} =
        session
        |> PomodoroSession.changeset(%{status: :cancelled})
        |> Repo.update()

      broadcast(scope, :pomodoro_cancelled, updated)
      {:ok, updated}
    else
      {:ok, session}
    end
  end

  defp cancel_active_sessions(%Scope{} = scope) do
    from(s in PomodoroSession,
      where: s.user_id == ^scope.user.id and s.status == :in_progress
    )
    |> Repo.update_all(set: [status: :cancelled])
  end

  def get_active_session(%Scope{} = scope) do
    PomodoroSession
    |> where(user_id: ^scope.user.id, status: :in_progress)
    |> order_by(desc: :started_at)
    |> limit(1)
    |> Repo.one()
  end

  def get_session!(%Scope{} = scope, id) do
    Repo.get_by!(PomodoroSession, id: id, user_id: scope.user.id)
  end

  def list_today_sessions(%Scope{} = scope) do
    today_start = DateTime.new!(Date.utc_today(), ~T[00:00:00], "Etc/UTC")

    PomodoroSession
    |> where(user_id: ^scope.user.id)
    |> where([s], s.started_at >= ^today_start)
    |> order_by(desc: :started_at)
    |> Repo.all()
  end

  def get_today_stats(%Scope{} = scope) do
    today_start = DateTime.new!(Date.utc_today(), ~T[00:00:00], "Etc/UTC")

    stats =
      from(s in PomodoroSession,
        where: s.user_id == ^scope.user.id,
        where: s.started_at >= ^today_start,
        where: s.status == :completed,
        select: %{
          sessions: count(s.id),
          total_minutes: coalesce(sum(s.duration_minutes), 0)
        }
      )
      |> Repo.one()

    stats || %{sessions: 0, total_minutes: 0}
  end

  def xp_for_duration(duration), do: Map.get(@xp_table, duration, {30, 15})

  defp tap_ok({:ok, record} = result, fun) do
    fun.(record)
    result
  end

  defp tap_ok(error, _fun), do: error
end
