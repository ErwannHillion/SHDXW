defmodule Shdxw.Gamification do
  @moduledoc """
  The Gamification context. Manages XP, levels, gold, streaks, and rewards.
  Central orchestrator for all gamification mechanics.
  """

  import Ecto.Query, warn: false
  alias Shdxw.Repo
  alias Shdxw.Accounts.Scope
  alias Shdxw.Gamification.{UserProfile, XpEvent}

  @topic_prefix "gamification"

  @level_titles %{
    1 => "Novice",
    5 => "Apprenti",
    10 => "Initie",
    15 => "Adepte",
    20 => "Expert",
    25 => "Maitre",
    30 => "Grand Maitre",
    40 => "Legendaire",
    50 => "Mythique",
    75 => "Divin",
    100 => "Transcendant"
  }

  @xp_rewards %{
    todo_low: {10, 5},
    todo_medium: {20, 10},
    todo_high: {35, 20},
    todo_urgent: {50, 30},
    todo_early_bonus: {10, 5},
    habit_daily: {15, 8},
    habit_weekly: {25, 15},
    habit_streak_7: {50, 25},
    pomodoro_25: {30, 15},
    pomodoro_45: {55, 30},
    pomodoro_60: {70, 40},
    daily_login: {5, 3},
    streak_7: {100, 50},
    streak_30: {500, 250},
    streak_100: {2000, 1000}
  }

  # --- PubSub ---

  defp topic(%Scope{user: user}), do: "#{@topic_prefix}:#{user.id}"

  def subscribe(%Scope{} = scope) do
    Phoenix.PubSub.subscribe(Shdxw.PubSub, topic(scope))
  end

  defp broadcast(%Scope{} = scope, event, payload) do
    Phoenix.PubSub.broadcast(Shdxw.PubSub, topic(scope), {event, payload})
  end

  # --- Profile ---

  def get_or_create_profile(%Scope{} = scope) do
    case Repo.get_by(UserProfile, user_id: scope.user.id) do
      nil ->
        {:ok, profile} =
          %UserProfile{user_id: scope.user.id}
          |> UserProfile.changeset(%{})
          |> Repo.insert()

        maybe_update_daily_streak(scope, profile)

      profile ->
        maybe_update_daily_streak(scope, profile)
    end
  end

  defp maybe_update_daily_streak(%Scope{} = scope, %UserProfile{} = profile) do
    today = Date.utc_today()

    if profile.last_active_date != today do
      {new_streak, streak_broken} =
        cond do
          profile.last_active_date == nil ->
            {1, false}

          Date.diff(today, profile.last_active_date) == 1 ->
            {profile.current_streak + 1, false}

          Date.diff(today, profile.last_active_date) > 1 ->
            # Check for streak freeze
            has_freeze = check_streak_freeze(scope)
            if has_freeze, do: {profile.current_streak, false}, else: {1, true}

          true ->
            {profile.current_streak, false}
        end

      longest = max(new_streak, profile.longest_streak)
      title = title_for_level(profile.level)

      {:ok, updated} =
        profile
        |> UserProfile.changeset(%{
          last_active_date: today,
          current_streak: new_streak,
          longest_streak: longest,
          title: title
        })
        |> Repo.update()

      # Award streak milestone bonuses
      if not streak_broken do
        check_streak_milestones(scope, new_streak, profile.current_streak)
      end

      broadcast(scope, :streak_updated, updated)
      updated
    else
      profile
    end
  end

  defp check_streak_freeze(%Scope{} = scope) do
    now = DateTime.utc_now()

    from(ui in Shdxw.Shop.UserItem,
      join: si in Shdxw.Shop.ShopItem,
      on: ui.shop_item_id == si.id,
      where: ui.user_id == ^scope.user.id,
      where: ui.active == true,
      where: si.effect == "streak_freeze",
      where: ui.expires_at > ^now
    )
    |> Repo.exists?()
  end

  defp check_streak_milestones(%Scope{} = scope, new_streak, old_streak) do
    milestones = [{7, :streak_7}, {30, :streak_30}, {100, :streak_100}]

    Enum.each(milestones, fn {threshold, reward_key} ->
      if new_streak >= threshold and old_streak < threshold do
        {xp, gold} = @xp_rewards[reward_key]
        award_xp_and_gold(scope, "streak", nil, xp, gold, "Milestone streak #{threshold} jours !")
      end
    end)
  end

  # --- XP & Gold ---

  def award_xp_and_gold(%Scope{} = scope, source, source_id, base_xp, gold, description) do
    profile = get_or_create_profile(scope)

    # Apply XP multiplier from active boosts
    multiplier = get_xp_multiplier(scope)
    final_xp = round(base_xp * multiplier)

    # Apply gold multiplier
    gold_multiplier = get_gold_multiplier(scope)
    final_gold = round(gold * gold_multiplier)

    new_xp = profile.xp + final_xp
    new_gold = profile.gold + final_gold
    new_level = calculate_level(new_xp)
    leveled_up = new_level > profile.level
    title = title_for_level(new_level)

    {:ok, updated_profile} =
      profile
      |> UserProfile.changeset(%{
        xp: new_xp,
        level: new_level,
        gold: new_gold,
        total_gold_earned: profile.total_gold_earned + final_gold,
        title: title
      })
      |> Repo.update()

    # Log the event
    {:ok, event} =
      %XpEvent{user_id: scope.user.id}
      |> XpEvent.changeset(%{
        source: source,
        source_id: source_id,
        xp_amount: final_xp,
        gold_amount: final_gold,
        description: description
      })
      |> Repo.insert()

    broadcast(scope, :xp_gained, %{profile: updated_profile, event: event})

    if leveled_up do
      broadcast(scope, :level_up, %{profile: updated_profile, new_level: new_level})
    end

    {:ok, %{profile: updated_profile, event: event, leveled_up: leveled_up}}
  end

  def get_xp_multiplier(%Scope{} = scope) do
    now = DateTime.utc_now()

    multipliers =
      from(ui in Shdxw.Shop.UserItem,
        join: si in Shdxw.Shop.ShopItem,
        on: ui.shop_item_id == si.id,
        where: ui.user_id == ^scope.user.id,
        where: ui.active == true,
        where: si.effect |> like("xp_multiplier_%"),
        where: ui.expires_at > ^now,
        select: si.effect
      )
      |> Repo.all()

    Enum.reduce(multipliers, 1.0, fn effect, acc ->
      case effect do
        "xp_multiplier_2x" -> acc * 2.0
        "xp_multiplier_3x" -> acc * 3.0
        "xp_multiplier_5x" -> acc * 5.0
        _ -> acc
      end
    end)
  end

  defp get_gold_multiplier(%Scope{} = scope) do
    now = DateTime.utc_now()

    multipliers =
      from(ui in Shdxw.Shop.UserItem,
        join: si in Shdxw.Shop.ShopItem,
        on: ui.shop_item_id == si.id,
        where: ui.user_id == ^scope.user.id,
        where: ui.active == true,
        where: si.effect |> like("gold_multiplier_%"),
        where: ui.expires_at > ^now,
        select: si.effect
      )
      |> Repo.all()

    Enum.reduce(multipliers, 1.0, fn effect, acc ->
      case effect do
        "gold_multiplier_2x" -> acc * 2.0
        _ -> acc
      end
    end)
  end

  # --- Todo Integration ---

  def on_todo_completed(%Scope{} = scope, todo) do
    {base_xp, gold} =
      case todo.priority do
        :low -> @xp_rewards[:todo_low]
        :medium -> @xp_rewards[:todo_medium]
        :high -> @xp_rewards[:todo_high]
        :urgent -> @xp_rewards[:todo_urgent]
      end

    # Early completion bonus
    {bonus_xp, bonus_gold} =
      if todo.due_date && Date.compare(Date.utc_today(), todo.due_date) == :lt do
        @xp_rewards[:todo_early_bonus]
      else
        {0, 0}
      end

    total_xp = base_xp + bonus_xp
    total_gold = gold + bonus_gold
    label = priority_label(todo.priority)

    award_xp_and_gold(
      scope,
      "todo",
      todo.id,
      total_xp,
      total_gold,
      "Tache #{label} terminee"
    )

    # Update counter
    profile = get_or_create_profile(scope)

    profile
    |> UserProfile.changeset(%{total_todos_completed: profile.total_todos_completed + 1})
    |> Repo.update()

    # Update daily quests
    Shdxw.DailyQuests.update_quest_progress(scope, "complete_todos")

    if todo.priority == :urgent do
      Shdxw.DailyQuests.update_quest_progress(scope, "complete_urgent")
    end

    # Check achievements
    Shdxw.Achievements.check_and_award(scope, :todos)
  end

  defp priority_label(:low), do: "basse"
  defp priority_label(:medium), do: "moyenne"
  defp priority_label(:high), do: "haute"
  defp priority_label(:urgent), do: "urgente"

  # --- Level System ---

  def calculate_level(xp) when xp <= 0, do: 1
  def calculate_level(xp), do: floor(:math.sqrt(xp / 100)) + 1

  def xp_for_level(level) when level <= 1, do: 0
  def xp_for_level(level), do: (level - 1) * (level - 1) * 100

  def xp_progress_in_level(xp) do
    level = calculate_level(xp)
    current_level_xp = xp_for_level(level)
    next_level_xp = xp_for_level(level + 1)

    %{
      current: xp - current_level_xp,
      needed: next_level_xp - current_level_xp,
      percent: progress_percent(xp - current_level_xp, next_level_xp - current_level_xp)
    }
  end

  defp progress_percent(_current, 0), do: 0
  defp progress_percent(current, needed), do: round(current / needed * 100)

  def title_for_level(level) do
    @level_titles
    |> Enum.filter(fn {lvl, _} -> lvl <= level end)
    |> Enum.max_by(fn {lvl, _} -> lvl end, fn -> {1, "Novice"} end)
    |> elem(1)
  end

  # --- Stats & History ---

  def list_recent_events(%Scope{} = scope, opts \\ []) do
    limit = Keyword.get(opts, :limit, 10)

    XpEvent
    |> where(user_id: ^scope.user.id)
    |> order_by(desc: :inserted_at)
    |> limit(^limit)
    |> Repo.all()
  end

  def get_today_stats(%Scope{} = scope) do
    today_start = DateTime.new!(Date.utc_today(), ~T[00:00:00], "Etc/UTC")

    xp_today =
      from(e in XpEvent,
        where: e.user_id == ^scope.user.id,
        where: e.inserted_at >= ^today_start,
        select: coalesce(sum(e.xp_amount), 0)
      )
      |> Repo.one()

    gold_today =
      from(e in XpEvent,
        where: e.user_id == ^scope.user.id,
        where: e.inserted_at >= ^today_start,
        select: coalesce(sum(e.gold_amount), 0)
      )
      |> Repo.one()

    %{xp_today: xp_today, gold_today: gold_today}
  end

  def spend_gold(%Scope{} = scope, amount) do
    profile = get_or_create_profile(scope)

    if profile.gold >= amount do
      {:ok, updated} =
        profile
        |> UserProfile.changeset(%{gold: profile.gold - amount})
        |> Repo.update()

      broadcast(scope, :gold_spent, updated)
      {:ok, updated}
    else
      {:error, :insufficient_gold}
    end
  end

  def xp_rewards, do: @xp_rewards
end
