defmodule Shdxw.Todos do
  @moduledoc """
  The Todos context. Manages todo items scoped to users.
  """

  import Ecto.Query, warn: false
  alias Shdxw.Repo
  alias Shdxw.Accounts.Scope
  alias Shdxw.Todos.Todo

  @topic_prefix "todos"

  defp topic(%Scope{user: user}), do: "#{@topic_prefix}:#{user.id}"

  def subscribe(%Scope{} = scope) do
    Phoenix.PubSub.subscribe(Shdxw.PubSub, topic(scope))
  end

  defp broadcast(%Scope{} = scope, event, payload) do
    Phoenix.PubSub.broadcast(Shdxw.PubSub, topic(scope), {event, payload})
  end

  def list_todos(%Scope{} = scope, opts \\ []) do
    status_filter = Keyword.get(opts, :status)
    sort_by = Keyword.get(opts, :sort_by, :position)
    sort_order = Keyword.get(opts, :sort_order, :asc)
    hide_old_done = Keyword.get(opts, :hide_old_done, true)

    Todo
    |> where(user_id: ^scope.user.id)
    |> maybe_filter_status(status_filter)
    |> maybe_hide_old_done(hide_old_done)
    |> apply_sort(sort_by, sort_order)
    |> Repo.all()
  end

  @doc """
  Lists todos visible on a specific date.

  - Today: all active todos (pending/in_progress) + todos completed today
  - Past days: only todos completed on that specific day
  - Future: empty
  """
  def list_todos_for_date(%Scope{} = scope, %Date{} = date) do
    today = Date.utc_today()

    cond do
      Date.compare(date, today) == :eq ->
        Todo
        |> where(user_id: ^scope.user.id)
        |> where([t], t.status in [:pending, :in_progress] or t.completed_at == ^date)
        |> order_by(asc: :position)
        |> Repo.all()

      Date.compare(date, today) == :lt ->
        Todo
        |> where(user_id: ^scope.user.id)
        |> where(completed_at: ^date)
        |> order_by(asc: :position)
        |> Repo.all()

      true ->
        []
    end
  end

  defp maybe_filter_status(query, nil), do: query
  defp maybe_filter_status(query, :all), do: query
  defp maybe_filter_status(query, status), do: where(query, status: ^status)

  defp maybe_hide_old_done(query, false), do: query

  defp maybe_hide_old_done(query, true) do
    today = Date.utc_today()
    where(query, [t], t.status != :done or t.completed_at == ^today or is_nil(t.completed_at))
  end

  defp apply_sort(query, :position, order) do
    order_by(query, [{^order, :position}, {^order, :inserted_at}])
  end

  defp apply_sort(query, :priority, order) do
    order_by(query, [t], [
      {^order,
       fragment(
         "CASE ? WHEN 'urgent' THEN 0 WHEN 'high' THEN 1 WHEN 'medium' THEN 2 WHEN 'low' THEN 3 END",
         t.priority
       )}
    ])
  end

  defp apply_sort(query, :due_date, order) do
    order_by(query, [t], [{^order, coalesce(t.due_date, ^~D[9999-12-31])}])
  end

  defp apply_sort(query, _field, order) do
    order_by(query, [{^order, :position}])
  end

  def get_todo!(%Scope{} = scope, id) do
    Repo.get_by!(Todo, id: id, user_id: scope.user.id)
  end

  def get_stats(%Scope{} = scope) do
    Todo
    |> where(user_id: ^scope.user.id)
    |> group_by(:status)
    |> select([t], {t.status, count(t.id)})
    |> Repo.all()
    |> Map.new()
    |> then(fn counts ->
      %{
        pending: Map.get(counts, :pending, 0),
        in_progress: Map.get(counts, :in_progress, 0),
        done: Map.get(counts, :done, 0),
        total:
          Map.get(counts, :pending, 0) +
            Map.get(counts, :in_progress, 0) +
            Map.get(counts, :done, 0)
      }
    end)
  end

  def create_todo(%Scope{} = scope, attrs) do
    next_position = get_next_position(scope)

    %Todo{user_id: scope.user.id, position: next_position}
    |> Todo.changeset(attrs)
    |> Repo.insert()
    |> tap_ok(fn todo -> broadcast(scope, :todo_created, todo) end)
  end

  defp get_next_position(%Scope{} = scope) do
    Todo
    |> where(user_id: ^scope.user.id)
    |> select([t], coalesce(max(t.position), -1) + 1)
    |> Repo.one()
  end

  def update_todo(%Scope{} = scope, %Todo{} = todo, attrs) do
    true = todo.user_id == scope.user.id

    attrs = maybe_set_completed_at(todo, attrs)

    todo
    |> Todo.changeset(attrs)
    |> Repo.update()
    |> tap_ok(fn todo -> broadcast(scope, :todo_updated, todo) end)
  end

  def cycle_todo_status(%Scope{} = scope, %Todo{} = todo) do
    next_status =
      case todo.status do
        :pending -> :in_progress
        :in_progress -> :done
        :done -> :pending
      end

    completed_at = if next_status == :done, do: Date.utc_today(), else: nil

    todo
    |> Todo.status_changeset(%{status: next_status, completed_at: completed_at})
    |> Repo.update()
    |> tap_ok(fn todo -> broadcast(scope, :todo_updated, todo) end)
  end

  def delete_todo(%Scope{} = scope, %Todo{} = todo) do
    true = todo.user_id == scope.user.id

    Repo.delete(todo)
    |> tap_ok(fn todo -> broadcast(scope, :todo_deleted, todo) end)
  end

  def change_todo(%Todo{} = todo, attrs \\ %{}) do
    Todo.changeset(todo, attrs)
  end

  # Auto-set completed_at when status changes to/from :done via update_todo
  defp maybe_set_completed_at(%Todo{} = todo, attrs) do
    new_status =
      case attrs do
        %{status: s} -> to_string(s)
        %{"status" => s} -> to_string(s)
        _ -> nil
      end

    cond do
      new_status == "done" && todo.status != :done ->
        Map.put(attrs, :completed_at, Date.utc_today())

      new_status != nil && new_status != "done" && todo.status == :done ->
        Map.put(attrs, :completed_at, nil)

      true ->
        attrs
    end
  end

  defp tap_ok({:ok, record} = result, fun) do
    fun.(record)
    result
  end

  defp tap_ok(error, _fun), do: error
end
