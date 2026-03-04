defmodule Shdxw.DailyQuests do
  @moduledoc """
  The DailyQuests context. Manages auto-generated daily challenges.
  """

  import Ecto.Query, warn: false
  alias Shdxw.Repo
  alias Shdxw.Accounts.Scope
  alias Shdxw.DailyQuests.DailyQuest

  @topic_prefix "daily_quests"

  @quest_templates [
    %{
      type: "complete_todos",
      descriptions: ["Terminer %{n} tache(s)"],
      targets: [2, 3, 5],
      xp: [30, 50, 80],
      gold: [15, 25, 40]
    },
    %{
      type: "complete_urgent",
      descriptions: ["Terminer %{n} tache(s) urgente(s)"],
      targets: [1, 2],
      xp: [40, 70],
      gold: [20, 35]
    },
    %{
      type: "pomodoro_session",
      descriptions: ["Completer %{n} session(s) pomodoro"],
      targets: [1, 2, 3],
      xp: [30, 55, 80],
      gold: [15, 30, 40]
    },
    %{
      type: "complete_habits",
      descriptions: ["Completer %{n} habitude(s)"],
      targets: [2, 3, 5],
      xp: [25, 40, 65],
      gold: [12, 20, 30]
    },
    %{
      type: "streak_maintain",
      descriptions: ["Maintenir votre streak"],
      targets: [1],
      xp: [25],
      gold: [15]
    }
  ]

  defp topic(%Scope{user: user}), do: "#{@topic_prefix}:#{user.id}"

  def subscribe(%Scope{} = scope) do
    Phoenix.PubSub.subscribe(Shdxw.PubSub, topic(scope))
  end

  defp broadcast(%Scope{} = scope, event, payload) do
    Phoenix.PubSub.broadcast(Shdxw.PubSub, topic(scope), {event, payload})
  end

  def get_or_generate_today_quests(%Scope{} = scope) do
    today = Date.utc_today()

    # Expire old quests first
    expire_old_quests(scope)

    existing =
      DailyQuest
      |> where(user_id: ^scope.user.id, quest_date: ^today)
      |> where([q], q.status in [:active, :completed])
      |> order_by(asc: :inserted_at)
      |> Repo.all()

    if length(existing) >= 3 do
      existing
    else
      generate_quests(scope, today, 3 - length(existing))
      |> then(fn _new -> existing ++ list_today_quests(scope) end)
      |> Enum.take(3)
    end
  end

  defp list_today_quests(%Scope{} = scope) do
    today = Date.utc_today()

    DailyQuest
    |> where(user_id: ^scope.user.id, quest_date: ^today)
    |> where([q], q.status in [:active, :completed])
    |> order_by(asc: :inserted_at)
    |> Repo.all()
  end

  defp generate_quests(%Scope{} = scope, date, count) do
    templates = Enum.shuffle(@quest_templates) |> Enum.take(count)

    Enum.map(templates, fn template ->
      idx = :rand.uniform(length(template.targets)) - 1
      target = Enum.at(template.targets, idx)
      xp = Enum.at(template.xp, idx)
      gold = Enum.at(template.gold, idx)
      desc_template = List.first(template.descriptions)
      description = String.replace(desc_template, "%{n}", to_string(target))

      %DailyQuest{user_id: scope.user.id}
      |> DailyQuest.changeset(%{
        quest_type: template.type,
        description: description,
        target_value: target,
        xp_reward: xp,
        gold_reward: gold,
        quest_date: date,
        status: :active
      })
      |> Repo.insert!()
    end)
  end

  def update_quest_progress(%Scope{} = scope, quest_type, increment \\ 1) do
    today = Date.utc_today()

    quests =
      DailyQuest
      |> where(
        user_id: ^scope.user.id,
        quest_date: ^today,
        quest_type: ^quest_type,
        status: :active
      )
      |> Repo.all()

    Enum.each(quests, fn quest ->
      new_value = min(quest.current_value + increment, quest.target_value)

      if new_value >= quest.target_value do
        {:ok, completed} =
          quest
          |> DailyQuest.changeset(%{
            current_value: new_value,
            status: :completed,
            completed_at: DateTime.utc_now() |> DateTime.truncate(:second)
          })
          |> Repo.update()

        # Award quest rewards
        Shdxw.Gamification.award_xp_and_gold(
          scope,
          "quest",
          quest.id,
          quest.xp_reward,
          quest.gold_reward,
          "Quete: #{quest.description}"
        )

        broadcast(scope, :quest_completed, completed)
      else
        quest
        |> DailyQuest.changeset(%{current_value: new_value})
        |> Repo.update()

        broadcast(scope, :quest_progress, %{quest_type: quest_type, new_value: new_value})
      end
    end)
  end

  defp expire_old_quests(%Scope{} = scope) do
    today = Date.utc_today()

    from(q in DailyQuest,
      where: q.user_id == ^scope.user.id,
      where: q.quest_date < ^today,
      where: q.status == :active
    )
    |> Repo.update_all(set: [status: :expired])
  end
end
