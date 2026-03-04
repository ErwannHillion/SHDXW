defmodule ShdxwWeb.TodoLive.Index do
  use ShdxwWeb, :live_view

  alias Shdxw.Todos
  alias Shdxw.Todos.Todo
  alias Shdxw.Gamification

  import ShdxwWeb.Components.GamificationBar
  import ShdxwWeb.Components.AppNav

  @impl true
  def mount(_params, _session, socket) do
    scope = socket.assigns.current_scope

    if connected?(socket) do
      Todos.subscribe(scope)
      Gamification.subscribe(scope)
    end

    todos = Todos.list_todos(scope)
    stats = Todos.get_stats(scope)
    changeset = Todos.change_todo(%Todo{})
    profile = Gamification.get_or_create_profile(scope)

    {:ok,
     socket
     |> assign(:page_title, "Todo List")
     |> assign(:todos, todos)
     |> assign(:stats, stats)
     |> assign(:status_filter, :all)
     |> assign(:sort_by, :position)
     |> assign(:sort_order, :asc)
     |> assign(:view_mode, :kanban)
     |> assign(:selected_date, Date.utc_today())
     |> assign(:editing_todo_id, nil)
     |> assign(:edit_form, nil)
     |> assign(:show_new_form, false)
     |> assign(:form, to_form(changeset))
     |> assign(:profile, profile)
     |> assign(:xp_progress, Gamification.xp_progress_in_level(profile.xp))
     |> assign(:current_page, :todos)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-black">
      <%!-- Background effects --%>
      <div class="fixed inset-0 bg-gradient-to-br from-black via-purple-950/30 to-black pointer-events-none" />
      <div class="fixed inset-0 pointer-events-none">
        <div class="absolute top-1/4 left-1/4 w-96 h-96 bg-purple-600/5 rounded-full blur-3xl" />
        <div class="absolute bottom-1/4 right-1/4 w-96 h-96 bg-violet-600/5 rounded-full blur-3xl" />
      </div>

      <%!-- Header --%>
      <div class="relative z-20 flex items-center justify-between px-6 py-4 border-b border-white/5 bg-black/80 backdrop-blur-sm">
        <a
          href="/"
          class="text-2xl font-black text-transparent bg-clip-text bg-gradient-to-r from-purple-500 to-violet-500 tracking-wider"
        >
          SHDXW
        </a>
      </div>

      <.gamification_bar profile={@profile} xp_progress={@xp_progress} />
      <.app_nav current_page={@current_page} current_scope={@current_scope} />

      <%!-- Flash --%>
      <Layouts.flash_group flash={@flash} />

      <%!-- Content --%>
      <div class={[
        "relative z-10 px-6 py-8 mx-auto",
        @view_mode == :kanban && "max-w-7xl",
        @view_mode != :kanban && "max-w-4xl"
      ]}>
        <%!-- Header --%>
        <div class="mb-10">
          <h1 class="text-5xl font-black text-white tracking-wider mb-2">
            <span class="text-purple-500">Todo</span> List
          </h1>
          <div class="w-32 h-1 bg-gradient-to-r from-purple-500 to-transparent rounded-full mb-8" />

          <%!-- Stats --%>
          <div class="grid grid-cols-4 gap-4 mb-6">
            <div class="bg-gradient-to-br from-purple-950/40 to-black border border-purple-500/20 rounded-2xl p-4 text-center">
              <div class="text-3xl font-black text-purple-400">{@stats.total}</div>
              <div class="text-xs text-white/40 tracking-wider uppercase mt-1">Total</div>
            </div>
            <div class="bg-gradient-to-br from-purple-950/40 to-black border border-purple-500/20 rounded-2xl p-4 text-center">
              <div class="text-3xl font-black text-amber-400">{@stats.pending}</div>
              <div class="text-xs text-white/40 tracking-wider uppercase mt-1">En attente</div>
            </div>
            <div class="bg-gradient-to-br from-purple-950/40 to-black border border-purple-500/20 rounded-2xl p-4 text-center">
              <div class="text-3xl font-black text-blue-400">{@stats.in_progress}</div>
              <div class="text-xs text-white/40 tracking-wider uppercase mt-1">En cours</div>
            </div>
            <div class="bg-gradient-to-br from-purple-950/40 to-black border border-purple-500/20 rounded-2xl p-4 text-center">
              <div class="text-3xl font-black text-emerald-400">{@stats.done}</div>
              <div class="text-xs text-white/40 tracking-wider uppercase mt-1">Terminé</div>
            </div>
          </div>

          <%!-- Progress bar --%>
          <div :if={@stats.total > 0}>
            <div class="flex justify-between text-xs text-white/40 mb-2">
              <span class="tracking-wider uppercase">Progression</span>
              <span>{progress_percent(@stats)}%</span>
            </div>
            <div class="w-full h-2 bg-white/5 rounded-full overflow-hidden">
              <div
                class="h-full bg-gradient-to-r from-purple-600 to-violet-500 rounded-full transition-all duration-500"
                style={"width: #{progress_percent(@stats)}%"}
              />
            </div>
          </div>
        </div>

        <%!-- Controls --%>
        <div class="flex flex-wrap items-center justify-between gap-3 mb-8">
          <div class="flex gap-3 items-center">
            <%!-- View mode toggle --%>
            <div class="flex bg-white/5 rounded-lg p-1 border border-white/10">
              <button
                phx-click="switch_view"
                phx-value-mode="list"
                class={[
                  "px-3 py-1.5 rounded-md text-sm transition-all",
                  @view_mode == :list && "bg-purple-600 text-white shadow-lg shadow-purple-600/30",
                  @view_mode != :list && "text-white/40 hover:text-white/70"
                ]}
              >
                <.icon name="hero-bars-3" class="size-4" />
              </button>
              <button
                phx-click="switch_view"
                phx-value-mode="kanban"
                class={[
                  "px-3 py-1.5 rounded-md text-sm transition-all",
                  @view_mode == :kanban && "bg-purple-600 text-white shadow-lg shadow-purple-600/30",
                  @view_mode != :kanban && "text-white/40 hover:text-white/70"
                ]}
              >
                <.icon name="hero-view-columns" class="size-4" />
              </button>
              <button
                phx-click="switch_view"
                phx-value-mode="day"
                class={[
                  "px-3 py-1.5 rounded-md text-sm transition-all",
                  @view_mode == :day && "bg-purple-600 text-white shadow-lg shadow-purple-600/30",
                  @view_mode != :day && "text-white/40 hover:text-white/70"
                ]}
              >
                <.icon name="hero-calendar-days" class="size-4" />
              </button>
            </div>

            <%!-- Filter tabs (list mode only) --%>
            <div :if={@view_mode == :list} class="flex gap-1">
              <button
                :for={{label, value} <- filter_options()}
                phx-click="filter"
                phx-value-status={value}
                class={[
                  "px-3 py-1.5 rounded-lg text-sm transition-all",
                  @status_filter == value &&
                    "bg-purple-600/20 text-purple-400 border border-purple-500/30",
                  @status_filter != value &&
                    "text-white/40 hover:text-white/60 border border-transparent"
                ]}
              >
                {label}
              </button>
            </div>
          </div>

          <div class="flex gap-2">
            <%!-- Sort (list mode only) --%>
            <div :if={@view_mode == :list} class="dropdown dropdown-end">
              <div
                tabindex="0"
                role="button"
                class="px-3 py-1.5 rounded-lg text-sm text-white/40 hover:text-white/70 border border-white/10 hover:border-white/20 transition-all cursor-pointer flex items-center gap-1"
              >
                <.icon name="hero-arrows-up-down" class="size-4" /> Trier
              </div>
              <ul
                tabindex="0"
                class="dropdown-content menu bg-black border border-purple-500/20 rounded-xl z-10 w-44 p-2 shadow-2xl shadow-purple-600/10 mt-2"
              >
                <li :for={{label, value} <- sort_options()}>
                  <button
                    phx-click="sort"
                    phx-value-field={value}
                    class={[
                      "text-sm",
                      @sort_by == value && "text-purple-400",
                      @sort_by != value && "text-white/60"
                    ]}
                  >
                    {label}
                    <.icon
                      :if={@sort_by == value}
                      name={if @sort_order == :asc, do: "hero-chevron-up", else: "hero-chevron-down"}
                      class="size-3"
                    />
                  </button>
                </li>
              </ul>
            </div>

            <%!-- Add button --%>
            <button
              phx-click="toggle_new_form"
              class="px-4 py-1.5 bg-purple-600 hover:bg-purple-700 text-white rounded-lg text-sm font-semibold shadow-lg shadow-purple-600/30 hover:shadow-purple-600/50 transition-all flex items-center gap-2"
            >
              <.icon name="hero-plus" class="size-4" /> Ajouter
            </button>
          </div>
        </div>

        <%!-- New todo form --%>
        <div
          :if={@show_new_form}
          class="bg-gradient-to-br from-purple-950/40 to-black border border-purple-500/20 rounded-2xl p-6 mb-8 shadow-2xl shadow-purple-600/5"
        >
          <h3 class="font-black text-white tracking-wider mb-4">
            Nouvelle <span class="text-purple-500">tâche</span>
          </h3>
          <.form for={@form} phx-submit="save" phx-change="validate">
            <div class="mb-3">
              <label class="text-xs text-white/40 tracking-wider uppercase mb-1 block">Titre</label>
              <input
                type="text"
                name={@form[:title].name}
                value={@form[:title].value}
                placeholder="Que devez-vous faire ?"
                required
                class="w-full bg-white/5 border border-white/10 focus:border-purple-500/50 rounded-lg px-4 py-2.5 text-white placeholder-white/20 outline-none transition-all"
              />
            </div>
            <div class="mb-3">
              <label class="text-xs text-white/40 tracking-wider uppercase mb-1 block">
                Description
              </label>
              <textarea
                name={@form[:description].name}
                placeholder="Détails optionnels..."
                rows="2"
                class="w-full bg-white/5 border border-white/10 focus:border-purple-500/50 rounded-lg px-4 py-2.5 text-white placeholder-white/20 outline-none transition-all resize-none"
              >{@form[:description].value}</textarea>
            </div>
            <div class="grid grid-cols-2 gap-4 mb-4">
              <div>
                <label class="text-xs text-white/40 tracking-wider uppercase mb-1 block">
                  Priorité
                </label>
                <select
                  name={@form[:priority].name}
                  class="w-full bg-white/5 border border-white/10 focus:border-purple-500/50 rounded-lg px-4 py-2.5 text-white outline-none transition-all"
                >
                  {Phoenix.HTML.Form.options_for_select(priority_options(), @form[:priority].value)}
                </select>
              </div>
              <div>
                <label class="text-xs text-white/40 tracking-wider uppercase mb-1 block">
                  Échéance
                </label>
                <input
                  type="date"
                  name={@form[:due_date].name}
                  value={@form[:due_date].value}
                  class="w-full bg-white/5 border border-white/10 focus:border-purple-500/50 rounded-lg px-4 py-2.5 text-white outline-none transition-all"
                />
              </div>
            </div>
            <div class="flex gap-3">
              <button
                type="submit"
                class="px-5 py-2 bg-purple-600 hover:bg-purple-700 text-white rounded-lg text-sm font-semibold shadow-lg shadow-purple-600/30 transition-all flex items-center gap-2"
              >
                <.icon name="hero-plus" class="size-4" /> Créer
              </button>
              <button
                type="button"
                phx-click="toggle_new_form"
                class="px-5 py-2 text-white/40 hover:text-white/70 border border-white/10 hover:border-white/20 rounded-lg text-sm transition-all"
              >
                Annuler
              </button>
            </div>
          </.form>
        </div>

        <%!-- === KANBAN VIEW === --%>
        <div
          :if={@view_mode == :kanban}
          id="kanban-board"
          phx-hook="KanbanDrag"
          class="grid grid-cols-3 gap-5"
        >
          <.kanban_column
            status={:pending}
            label="En attente"
            icon="hero-clock"
            color="amber"
            todos={kanban_todos(@todos, :pending)}
            editing_todo_id={@editing_todo_id}
            edit_form={@edit_form}
          />
          <.kanban_column
            status={:in_progress}
            label="En cours"
            icon="hero-arrow-path"
            color="blue"
            todos={kanban_todos(@todos, :in_progress)}
            editing_todo_id={@editing_todo_id}
            edit_form={@edit_form}
          />
          <.kanban_column
            status={:done}
            label="Terminé"
            icon="hero-check-circle-solid"
            color="emerald"
            todos={kanban_todos(@todos, :done)}
            editing_todo_id={@editing_todo_id}
            edit_form={@edit_form}
          />
        </div>

        <%!-- === DAY VIEW === --%>
        <div :if={@view_mode == :day}>
          <%!-- Day navigation --%>
          <div class="flex items-center justify-center gap-4 mb-8">
            <button
              phx-click="prev_day"
              class="p-2 text-white/40 hover:text-purple-400 transition-colors"
            >
              <.icon name="hero-chevron-left" class="size-6" />
            </button>
            <div class="text-center min-w-[200px]">
              <div class="text-2xl font-black text-white tracking-wider">
                {format_day_label(@selected_date)}
              </div>
              <div class="text-sm text-white/30 mt-1">
                {Calendar.strftime(@selected_date, "%A")}
              </div>
            </div>
            <button
              phx-click="next_day"
              class={[
                "p-2 transition-colors",
                is_today?(@selected_date) && "text-white/10 cursor-not-allowed",
                !is_today?(@selected_date) && "text-white/40 hover:text-purple-400"
              ]}
              disabled={is_today?(@selected_date)}
            >
              <.icon name="hero-chevron-right" class="size-6" />
            </button>
          </div>
          <div class="flex justify-center mb-6">
            <button
              :if={!is_today?(@selected_date)}
              phx-click="go_today"
              class="px-3 py-1 text-xs text-purple-400 border border-purple-500/20 rounded-full hover:bg-purple-600/10 transition-all"
            >
              Aujourd'hui
            </button>
            <span :if={is_today?(@selected_date)} class="px-3 py-1 text-xs text-purple-400/60">
              Aujourd'hui
            </span>
          </div>

          <%!-- Day todos --%>
          <div class="space-y-3">
            <div
              :for={todo <- @todos}
              id={"day-todo-#{todo.id}"}
              class={[
                "bg-gradient-to-br from-purple-950/30 to-black border-l-4 border border-purple-500/10 rounded-xl p-4 transition-all duration-200 hover:border-purple-500/20 hover:shadow-lg hover:shadow-purple-600/5",
                priority_border(todo.priority),
                todo.status == :done && "opacity-50"
              ]}
            >
              <%= if @editing_todo_id == todo.id do %>
                <.inline_edit_form edit_form={@edit_form} todo={todo} />
              <% else %>
                <.todo_list_item todo={todo} />
              <% end %>
            </div>
          </div>

          <%!-- Day empty state --%>
          <div :if={@todos == []} class="text-center py-20">
            <.icon name="hero-calendar" class="size-20 mx-auto text-white/10 mb-6" />
            <p class="text-xl text-white/30 tracking-wider">
              <%= if is_today?(@selected_date) do %>
                Aucune tâche pour aujourd'hui
              <% else %>
                Aucune tâche terminée ce jour
              <% end %>
            </p>
          </div>
        </div>

        <%!-- === LIST VIEW === --%>
        <div :if={@view_mode == :list} class="space-y-3">
          <div
            :for={todo <- @todos}
            id={"todo-#{todo.id}"}
            class={[
              "bg-gradient-to-br from-purple-950/30 to-black border-l-4 border border-purple-500/10 rounded-xl p-4 transition-all duration-200 hover:border-purple-500/20 hover:shadow-lg hover:shadow-purple-600/5",
              priority_border(todo.priority),
              todo.status == :done && "opacity-50"
            ]}
          >
            <%= if @editing_todo_id == todo.id do %>
              <.inline_edit_form edit_form={@edit_form} todo={todo} />
            <% else %>
              <.todo_list_item todo={todo} />
            <% end %>
          </div>
        </div>

        <%!-- Empty state --%>
        <div :if={@todos == [] && @view_mode == :list} class="text-center py-20">
          <.icon name="hero-clipboard-document-list" class="size-20 mx-auto text-white/10 mb-6" />
          <p class="text-xl text-white/30 tracking-wider">
            <%= if @status_filter == :all do %>
              Aucune tâche pour le moment
            <% else %>
              Aucune tâche avec ce filtre
            <% end %>
          </p>
          <button
            :if={!@show_new_form}
            phx-click="toggle_new_form"
            class="mt-6 px-5 py-2.5 bg-purple-600 hover:bg-purple-700 text-white rounded-lg text-sm font-semibold shadow-lg shadow-purple-600/30 transition-all"
          >
            <.icon name="hero-plus" class="size-4" /> Créer une tâche
          </button>
        </div>
      </div>
    </div>
    """
  end

  # --- Components ---

  defp kanban_column(assigns) do
    ~H"""
    <div
      data-kanban-status={@status}
      class="bg-gradient-to-b from-purple-950/20 to-black/50 border border-purple-500/10 rounded-2xl p-4 min-h-[350px] transition-all duration-200"
    >
      <%!-- Column header --%>
      <div class="flex items-center gap-2 mb-5 px-1">
        <.icon name={@icon} class={"size-5 text-#{@color}-400"} />
        <h3 class="font-bold text-white/90 text-sm tracking-wider uppercase">{@label}</h3>
        <span class={"ml-auto text-xs font-bold px-2 py-0.5 rounded-full bg-#{@color}-400/10 text-#{@color}-400"}>
          {length(@todos)}
        </span>
      </div>

      <%!-- Cards --%>
      <div class="space-y-2">
        <div
          :for={todo <- @todos}
          id={"kanban-todo-#{todo.id}"}
          data-todo-id={todo.id}
          draggable="true"
          class={[
            "bg-black/60 border border-white/5 rounded-xl p-3 cursor-grab active:cursor-grabbing",
            "transition-all duration-200 hover:border-purple-500/20 hover:shadow-lg hover:shadow-purple-600/5",
            todo.status == :done && "opacity-50"
          ]}
        >
          <%= if @editing_todo_id == todo.id do %>
            <.inline_edit_form edit_form={@edit_form} todo={todo} />
          <% else %>
            <.todo_kanban_card todo={todo} />
          <% end %>
        </div>
      </div>

      <%!-- Empty column --%>
      <div :if={@todos == []} class="text-center py-12">
        <p class="text-xs text-white/20 tracking-wider">Glissez une tâche ici</p>
      </div>
    </div>
    """
  end

  defp todo_kanban_card(assigns) do
    ~H"""
    <div>
      <div class="flex items-start justify-between gap-2">
        <span class={[
          "font-semibold text-sm text-white/90",
          @todo.status == :done && "line-through text-white/40"
        ]}>
          {@todo.title}
        </span>
        <div class="flex gap-0.5 shrink-0">
          <button
            phx-click="edit"
            phx-value-id={@todo.id}
            class="p-1 text-white/20 hover:text-purple-400 transition-colors"
            title="Modifier"
          >
            <.icon name="hero-pencil-square" class="size-3" />
          </button>
          <button
            phx-click="delete"
            phx-value-id={@todo.id}
            data-confirm="Supprimer cette tâche ?"
            class="p-1 text-white/20 hover:text-red-400 transition-colors"
            title="Supprimer"
          >
            <.icon name="hero-trash" class="size-3" />
          </button>
        </div>
      </div>
      <p
        :if={@todo.description && @todo.description != ""}
        class="text-xs text-white/30 mt-1.5 line-clamp-2"
      >
        {@todo.description}
      </p>
      <div class="flex items-center gap-2 mt-2.5 flex-wrap">
        <span class={[
          "text-[10px] font-bold tracking-wider uppercase px-2 py-0.5 rounded-full",
          priority_pill(@todo.priority)
        ]}>
          {priority_label(@todo.priority)}
        </span>
        <div :if={@todo.due_date} class="flex items-center gap-1">
          <.icon
            name="hero-calendar"
            class={"size-3 #{if overdue?(@todo), do: "text-red-400", else: "text-white/20"}"}
          />
          <span class={[
            "text-[10px]",
            overdue?(@todo) && "text-red-400 font-semibold",
            !overdue?(@todo) && "text-white/30"
          ]}>
            {format_due_date(@todo.due_date)}
          </span>
        </div>
      </div>
    </div>
    """
  end

  defp todo_list_item(assigns) do
    ~H"""
    <div class="flex items-start gap-3">
      <button
        phx-click="cycle_status"
        phx-value-id={@todo.id}
        class="mt-1 cursor-pointer shrink-0"
        title="Changer le statut"
      >
        <.icon name={status_icon(@todo.status)} class={"size-6 #{status_color(@todo.status)}"} />
      </button>
      <div class="flex-1 min-w-0">
        <div class="flex items-center gap-2 flex-wrap">
          <span class={[
            "font-semibold text-white/90",
            @todo.status == :done && "line-through text-white/40"
          ]}>
            {@todo.title}
          </span>
          <span class={[
            "text-[10px] font-bold tracking-wider uppercase px-2 py-0.5 rounded-full",
            priority_pill(@todo.priority)
          ]}>
            {priority_label(@todo.priority)}
          </span>
        </div>
        <p
          :if={@todo.description && @todo.description != ""}
          class="text-sm text-white/30 mt-1 line-clamp-2"
        >
          {@todo.description}
        </p>
        <div :if={@todo.due_date} class="flex items-center gap-1 mt-1.5">
          <.icon
            name="hero-calendar"
            class={"size-3 #{if overdue?(@todo), do: "text-red-400", else: "text-white/20"}"}
          />
          <span class={[
            "text-xs",
            overdue?(@todo) && "text-red-400 font-semibold",
            !overdue?(@todo) && "text-white/30"
          ]}>
            {format_due_date(@todo.due_date)}
            <span :if={overdue?(@todo)} class="ml-1">en retard</span>
          </span>
        </div>
      </div>
      <div class="flex items-center gap-1 shrink-0">
        <button
          phx-click="edit"
          phx-value-id={@todo.id}
          class="p-1.5 text-white/20 hover:text-purple-400 transition-colors rounded-lg"
          title="Modifier"
        >
          <.icon name="hero-pencil-square" class="size-4" />
        </button>
        <button
          phx-click="delete"
          phx-value-id={@todo.id}
          data-confirm="Supprimer cette tâche ?"
          class="p-1.5 text-white/20 hover:text-red-400 transition-colors rounded-lg"
          title="Supprimer"
        >
          <.icon name="hero-trash" class="size-4" />
        </button>
      </div>
    </div>
    """
  end

  defp inline_edit_form(assigns) do
    ~H"""
    <div phx-click-away="cancel_edit">
      <.form for={@edit_form} phx-submit="save_edit" phx-change="validate_edit">
        <input type="hidden" name="todo_id" value={@todo.id} />
        <div class="mb-2">
          <input
            type="text"
            name={@edit_form[:title].name}
            value={@edit_form[:title].value}
            required
            class="w-full bg-white/5 border border-purple-500/30 focus:border-purple-500/60 rounded-lg px-3 py-2 text-white text-sm outline-none transition-all"
          />
        </div>
        <div class="mb-2">
          <textarea
            name={@edit_form[:description].name}
            rows="2"
            class="w-full bg-white/5 border border-white/10 focus:border-purple-500/30 rounded-lg px-3 py-2 text-white text-sm outline-none transition-all resize-none"
          >{@edit_form[:description].value}</textarea>
        </div>
        <div class="grid grid-cols-3 gap-2 mb-3">
          <select
            name={@edit_form[:priority].name}
            class="bg-white/5 border border-white/10 rounded-lg px-2 py-1.5 text-white text-xs outline-none"
          >
            {Phoenix.HTML.Form.options_for_select(priority_options(), @edit_form[:priority].value)}
          </select>
          <select
            name={@edit_form[:status].name}
            class="bg-white/5 border border-white/10 rounded-lg px-2 py-1.5 text-white text-xs outline-none"
          >
            {Phoenix.HTML.Form.options_for_select(status_options(), @edit_form[:status].value)}
          </select>
          <input
            type="date"
            name={@edit_form[:due_date].name}
            value={@edit_form[:due_date].value}
            class="bg-white/5 border border-white/10 rounded-lg px-2 py-1.5 text-white text-xs outline-none"
          />
        </div>
        <div class="flex gap-2">
          <button
            type="submit"
            class="px-3 py-1.5 bg-purple-600 hover:bg-purple-700 text-white rounded-lg text-xs font-semibold transition-all"
          >
            Sauvegarder
          </button>
          <button
            type="button"
            phx-click="cancel_edit"
            class="px-3 py-1.5 text-white/40 hover:text-white/60 text-xs transition-all"
          >
            Annuler
          </button>
        </div>
      </.form>
    </div>
    """
  end

  # --- Events ---

  @impl true
  def handle_event("toggle_new_form", _, socket) do
    {:noreply,
     socket
     |> assign(:show_new_form, !socket.assigns.show_new_form)
     |> assign(:form, to_form(Todos.change_todo(%Todo{})))}
  end

  def handle_event("switch_view", %{"mode" => mode}, socket) do
    view_mode = String.to_existing_atom(mode)
    scope = socket.assigns.current_scope

    socket =
      case view_mode do
        :kanban ->
          todos = Todos.list_todos(scope)
          socket |> assign(:todos, todos) |> assign(:status_filter, :all)

        :day ->
          date = Date.utc_today()
          todos = Todos.list_todos_for_date(scope, date)
          socket |> assign(:todos, todos) |> assign(:selected_date, date)

        _ ->
          socket
      end

    {:noreply, assign(socket, :view_mode, view_mode)}
  end

  def handle_event("prev_day", _, socket) do
    date = Date.add(socket.assigns.selected_date, -1)
    scope = socket.assigns.current_scope
    todos = Todos.list_todos_for_date(scope, date)

    {:noreply,
     socket
     |> assign(:selected_date, date)
     |> assign(:todos, todos)}
  end

  def handle_event("next_day", _, socket) do
    date = socket.assigns.selected_date
    today = Date.utc_today()

    if Date.compare(date, today) == :lt do
      new_date = Date.add(date, 1)
      scope = socket.assigns.current_scope
      todos = Todos.list_todos_for_date(scope, new_date)

      {:noreply,
       socket
       |> assign(:selected_date, new_date)
       |> assign(:todos, todos)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("go_today", _, socket) do
    date = Date.utc_today()
    scope = socket.assigns.current_scope
    todos = Todos.list_todos_for_date(scope, date)

    {:noreply,
     socket
     |> assign(:selected_date, date)
     |> assign(:todos, todos)}
  end

  def handle_event("validate", %{"todo" => params}, socket) do
    changeset =
      %Todo{}
      |> Todos.change_todo(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  def handle_event("save", %{"todo" => params}, socket) do
    scope = socket.assigns.current_scope

    case Todos.create_todo(scope, params) do
      {:ok, _todo} ->
        changeset = Todos.change_todo(%Todo{})

        {:noreply,
         socket
         |> put_flash(:info, "Tâche créée !")
         |> assign(:show_new_form, false)
         |> assign(:form, to_form(changeset))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def handle_event("cycle_status", %{"id" => id}, socket) do
    scope = socket.assigns.current_scope
    todo = Todos.get_todo!(scope, id)

    case Todos.cycle_todo_status(scope, todo) do
      {:ok, _todo} ->
        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Erreur lors du changement de statut")}
    end
  end

  def handle_event("move_to_status", %{"id" => id, "status" => status}, socket) do
    scope = socket.assigns.current_scope
    todo = Todos.get_todo!(scope, id)
    new_status = String.to_existing_atom(status)

    if todo.status != new_status do
      case Todos.update_todo(scope, todo, %{status: new_status}) do
        {:ok, _todo} ->
          {:noreply, socket}

        {:error, _changeset} ->
          {:noreply, put_flash(socket, :error, "Erreur lors du déplacement")}
      end
    else
      {:noreply, socket}
    end
  end

  def handle_event("edit", %{"id" => id}, socket) do
    scope = socket.assigns.current_scope
    todo = Todos.get_todo!(scope, id)
    changeset = Todos.change_todo(todo)

    {:noreply,
     socket
     |> assign(:editing_todo_id, String.to_integer(id))
     |> assign(:edit_form, to_form(changeset))}
  end

  def handle_event("cancel_edit", _, socket) do
    {:noreply,
     socket
     |> assign(:editing_todo_id, nil)
     |> assign(:edit_form, nil)}
  end

  def handle_event("validate_edit", %{"todo" => params}, socket) do
    scope = socket.assigns.current_scope
    todo = Todos.get_todo!(scope, socket.assigns.editing_todo_id)

    changeset =
      todo
      |> Todos.change_todo(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :edit_form, to_form(changeset))}
  end

  def handle_event("save_edit", %{"todo" => params}, socket) do
    scope = socket.assigns.current_scope
    todo = Todos.get_todo!(scope, socket.assigns.editing_todo_id)

    case Todos.update_todo(scope, todo, params) do
      {:ok, _todo} ->
        {:noreply,
         socket
         |> put_flash(:info, "Tâche mise à jour !")
         |> assign(:editing_todo_id, nil)
         |> assign(:edit_form, nil)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :edit_form, to_form(changeset))}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    scope = socket.assigns.current_scope
    todo = Todos.get_todo!(scope, id)

    case Todos.delete_todo(scope, todo) do
      {:ok, _todo} ->
        {:noreply, put_flash(socket, :info, "Tâche supprimée")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Erreur lors de la suppression")}
    end
  end

  def handle_event("filter", %{"status" => status}, socket) do
    status_atom =
      case status do
        "all" -> :all
        "pending" -> :pending
        "in_progress" -> :in_progress
        "done" -> :done
      end

    scope = socket.assigns.current_scope

    todos =
      Todos.list_todos(scope,
        status: status_atom,
        sort_by: socket.assigns.sort_by,
        sort_order: socket.assigns.sort_order
      )

    {:noreply,
     socket
     |> assign(:status_filter, status_atom)
     |> assign(:todos, todos)}
  end

  def handle_event("sort", %{"field" => field}, socket) do
    field_atom = String.to_existing_atom(field)

    {sort_by, sort_order} =
      if socket.assigns.sort_by == field_atom do
        order = if socket.assigns.sort_order == :asc, do: :desc, else: :asc
        {field_atom, order}
      else
        {field_atom, :asc}
      end

    scope = socket.assigns.current_scope

    todos =
      Todos.list_todos(scope,
        status: socket.assigns.status_filter,
        sort_by: sort_by,
        sort_order: sort_order
      )

    {:noreply,
     socket
     |> assign(:sort_by, sort_by)
     |> assign(:sort_order, sort_order)
     |> assign(:todos, todos)}
  end

  # --- PubSub ---

  @impl true
  def handle_info({event, _todo}, socket)
      when event in [:todo_created, :todo_updated, :todo_deleted] do
    {:noreply, reload_todos(socket)}
  end

  def handle_info({event, _}, socket) when event in [:xp_gained, :level_up, :streak_updated] do
    scope = socket.assigns.current_scope
    profile = Gamification.get_or_create_profile(scope)

    {:noreply,
     socket
     |> assign(:profile, profile)
     |> assign(:xp_progress, Gamification.xp_progress_in_level(profile.xp))}
  end

  def handle_info(_, socket), do: {:noreply, socket}

  # --- Helpers ---

  defp reload_todos(socket) do
    scope = socket.assigns.current_scope

    todos =
      case socket.assigns.view_mode do
        :day ->
          Todos.list_todos_for_date(scope, socket.assigns.selected_date)

        _ ->
          Todos.list_todos(scope,
            status: socket.assigns.status_filter,
            sort_by: socket.assigns.sort_by,
            sort_order: socket.assigns.sort_order
          )
      end

    socket
    |> assign(:todos, todos)
    |> assign(:stats, Todos.get_stats(scope))
  end

  defp kanban_todos(todos, status) do
    Enum.filter(todos, &(&1.status == status))
  end

  defp filter_options do
    [
      {"Tout", :all},
      {"En attente", :pending},
      {"En cours", :in_progress},
      {"Terminé", :done}
    ]
  end

  defp sort_options do
    [
      {"Position", :position},
      {"Priorité", :priority},
      {"Échéance", :due_date}
    ]
  end

  defp priority_options do
    [
      {"Basse", :low},
      {"Moyenne", :medium},
      {"Haute", :high},
      {"Urgente", :urgent}
    ]
  end

  defp status_options do
    [
      {"En attente", :pending},
      {"En cours", :in_progress},
      {"Terminé", :done}
    ]
  end

  defp priority_border(:urgent), do: "border-l-red-500"
  defp priority_border(:high), do: "border-l-amber-500"
  defp priority_border(:medium), do: "border-l-blue-500"
  defp priority_border(:low), do: "border-l-emerald-500"

  defp priority_pill(:urgent), do: "bg-red-400/10 text-red-400"
  defp priority_pill(:high), do: "bg-amber-400/10 text-amber-400"
  defp priority_pill(:medium), do: "bg-blue-400/10 text-blue-400"
  defp priority_pill(:low), do: "bg-emerald-400/10 text-emerald-400"

  defp priority_label(:urgent), do: "Urgente"
  defp priority_label(:high), do: "Haute"
  defp priority_label(:medium), do: "Moyenne"
  defp priority_label(:low), do: "Basse"

  defp status_icon(:pending), do: "hero-clock"
  defp status_icon(:in_progress), do: "hero-arrow-path"
  defp status_icon(:done), do: "hero-check-circle-solid"

  defp status_color(:pending), do: "text-amber-400"
  defp status_color(:in_progress), do: "text-blue-400"
  defp status_color(:done), do: "text-emerald-400"

  defp overdue?(%Todo{due_date: nil}), do: false

  defp overdue?(%Todo{due_date: date, status: status}) when status != :done do
    Date.compare(date, Date.utc_today()) == :lt
  end

  defp overdue?(_), do: false

  defp format_due_date(nil), do: nil
  defp format_due_date(date), do: Calendar.strftime(date, "%d/%m/%Y")

  defp is_today?(date), do: Date.compare(date, Date.utc_today()) == :eq

  defp format_day_label(date) do
    today = Date.utc_today()

    cond do
      Date.compare(date, today) == :eq -> "Aujourd'hui"
      Date.compare(date, Date.add(today, -1)) == :eq -> "Hier"
      true -> Calendar.strftime(date, "%d/%m/%Y")
    end
  end

  defp progress_percent(%{done: done, total: total}) when total > 0 do
    round(done / total * 100)
  end

  defp progress_percent(_), do: 0
end
