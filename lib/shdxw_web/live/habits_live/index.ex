defmodule ShdxwWeb.HabitsLive.Index do
  use ShdxwWeb, :live_view

  alias Shdxw.Habits
  alias Shdxw.Habits.Habit
  alias Shdxw.Gamification

  import ShdxwWeb.Components.GamificationBar
  import ShdxwWeb.Components.AppNav

  @impl true
  def mount(_params, _session, socket) do
    scope = socket.assigns.current_scope

    if connected?(socket) do
      Habits.subscribe(scope)
      Gamification.subscribe(scope)
    end

    profile = Gamification.get_or_create_profile(scope)
    habits_with_status = Habits.list_habits_with_today_status(scope)
    heatmap = Habits.get_weekly_heatmap(scope)

    {:ok,
     socket
     |> assign(:page_title, "Habitudes")
     |> assign(:profile, profile)
     |> assign(:xp_progress, Gamification.xp_progress_in_level(profile.xp))
     |> assign(:habits_with_status, habits_with_status)
     |> assign(:heatmap, heatmap)
     |> assign(:show_new_form, false)
     |> assign(:editing_habit_id, nil)
     |> assign(:form, to_form(Habits.change_habit(%Habit{})))
     |> assign(:edit_form, nil)
     |> assign(:current_page, :habits)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-black">
      <div class="fixed inset-0 bg-gradient-to-br from-black via-purple-950/30 to-black pointer-events-none" />
      <div class="fixed inset-0 pointer-events-none">
        <div class="absolute top-1/4 left-1/4 w-96 h-96 bg-purple-600/5 rounded-full blur-3xl" />
        <div class="absolute bottom-1/4 right-1/4 w-96 h-96 bg-violet-600/5 rounded-full blur-3xl" />
      </div>

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

      <Layouts.flash_group flash={@flash} />

      <div class="relative z-10 px-6 py-8 mx-auto max-w-4xl">
        <div class="mb-10">
          <h1 class="text-5xl font-black text-white tracking-wider mb-2">
            <span class="text-purple-500">Habi</span>tudes
          </h1>
          <div class="w-32 h-1 bg-gradient-to-r from-purple-500 to-transparent rounded-full mb-6" />
        </div>

        <%!-- Weekly Heatmap --%>
        <div class="bg-gradient-to-br from-purple-950/40 to-black border border-purple-500/20 rounded-2xl p-6 mb-8">
          <h3 class="text-xs text-white/40 tracking-wider uppercase mb-3">Activite de la semaine</h3>
          <div class="flex justify-center gap-2">
            <div :for={{date, count} <- @heatmap} class="text-center">
              <div class={[
                "w-10 h-10 rounded-lg flex items-center justify-center text-xs font-bold transition-all",
                count == 0 && "bg-white/5 text-white/20",
                count > 0 && count < 3 &&
                  "bg-purple-600/30 text-purple-300 border border-purple-500/20",
                count >= 3 && count < 5 &&
                  "bg-purple-600/50 text-purple-200 border border-purple-500/30",
                count >= 5 &&
                  "bg-purple-600 text-white border border-purple-400/40 shadow-lg shadow-purple-600/30"
              ]}>
                {count}
              </div>
              <div class="text-[9px] text-white/20 mt-1">{day_label(date)}</div>
            </div>
          </div>
        </div>

        <%!-- Add button --%>
        <div class="flex justify-end mb-6">
          <button
            phx-click="toggle_new_form"
            class="px-4 py-1.5 bg-purple-600 hover:bg-purple-700 text-white rounded-lg text-sm font-semibold shadow-lg shadow-purple-600/30 hover:shadow-purple-600/50 transition-all flex items-center gap-2"
          >
            <.icon name="hero-plus" class="size-4" /> Nouvelle habitude
          </button>
        </div>

        <%!-- New habit form --%>
        <div
          :if={@show_new_form}
          class="bg-gradient-to-br from-purple-950/40 to-black border border-purple-500/20 rounded-2xl p-6 mb-8"
        >
          <h3 class="font-black text-white tracking-wider mb-4">
            Nouvelle <span class="text-purple-500">habitude</span>
          </h3>
          <.form for={@form} phx-submit="save" phx-change="validate">
            <div class="mb-3">
              <label class="text-xs text-white/40 tracking-wider uppercase mb-1 block">Nom</label>
              <input
                type="text"
                name={@form[:name].name}
                value={@form[:name].value}
                placeholder="Ex: Mediter 10 minutes"
                required
                class="w-full bg-white/5 border border-white/10 focus:border-purple-500/50 rounded-lg px-4 py-2.5 text-white placeholder-white/20 outline-none transition-all"
              />
            </div>
            <div class="grid grid-cols-2 gap-4 mb-4">
              <div>
                <label class="text-xs text-white/40 tracking-wider uppercase mb-1 block">
                  Frequence
                </label>
                <select
                  name={@form[:frequency].name}
                  class="w-full bg-white/5 border border-white/10 focus:border-purple-500/50 rounded-lg px-4 py-2.5 text-white outline-none transition-all"
                >
                  <option value="daily" selected={@form[:frequency].value == :daily}>
                    Quotidien
                  </option>
                  <option value="weekly" selected={@form[:frequency].value == :weekly}>
                    Hebdomadaire
                  </option>
                </select>
              </div>
              <div>
                <label class="text-xs text-white/40 tracking-wider uppercase mb-1 block">
                  Couleur
                </label>
                <select
                  name={@form[:color].name}
                  class="w-full bg-white/5 border border-white/10 focus:border-purple-500/50 rounded-lg px-4 py-2.5 text-white outline-none transition-all"
                >
                  <option value="purple">Violet</option>
                  <option value="blue">Bleu</option>
                  <option value="emerald">Vert</option>
                  <option value="amber">Orange</option>
                  <option value="red">Rouge</option>
                </select>
              </div>
            </div>
            <div class="flex gap-3">
              <button
                type="submit"
                class="px-5 py-2 bg-purple-600 hover:bg-purple-700 text-white rounded-lg text-sm font-semibold shadow-lg shadow-purple-600/30 transition-all"
              >
                Creer
              </button>
              <button
                type="button"
                phx-click="toggle_new_form"
                class="px-5 py-2 text-white/40 hover:text-white/70 border border-white/10 rounded-lg text-sm transition-all"
              >
                Annuler
              </button>
            </div>
          </.form>
        </div>

        <%!-- Habits List --%>
        <div class="space-y-3">
          <div
            :for={{habit, completed_today} <- @habits_with_status}
            class={[
              "bg-gradient-to-br from-purple-950/30 to-black border rounded-xl p-4 transition-all duration-200 hover:shadow-lg hover:shadow-purple-600/5",
              completed_today && "border-emerald-500/20 opacity-80",
              !completed_today && "border-purple-500/10 hover:border-purple-500/20"
            ]}
          >
            <div class="flex items-center gap-4">
              <%!-- Completion toggle --%>
              <button
                phx-click={if completed_today, do: "uncomplete_habit", else: "complete_habit"}
                phx-value-id={habit.id}
                class={[
                  "w-10 h-10 rounded-xl flex items-center justify-center transition-all shrink-0",
                  completed_today && "bg-emerald-500/20 text-emerald-400 border border-emerald-500/30",
                  !completed_today &&
                    "bg-white/5 text-white/20 border border-white/10 hover:border-purple-500/30 hover:text-purple-400"
                ]}
              >
                <.icon name={if completed_today, do: "hero-check", else: "hero-plus"} class="size-5" />
              </button>

              <%!-- Habit info --%>
              <div class="flex-1 min-w-0">
                <div class="flex items-center gap-2">
                  <span class={[
                    "font-semibold text-white/90",
                    completed_today && "line-through text-white/40"
                  ]}>
                    {habit.name}
                  </span>
                  <span class={[
                    "text-[10px] font-bold tracking-wider uppercase px-2 py-0.5 rounded-full",
                    "bg-#{habit.color}-400/10 text-#{habit.color}-400"
                  ]}>
                    {if habit.frequency == :daily, do: "quotidien", else: "hebdo"}
                  </span>
                </div>
              </div>

              <%!-- Streak --%>
              <div class="flex items-center gap-1.5 shrink-0">
                <span class="text-orange-400 text-sm">&#x1F525;</span>
                <span class="text-orange-400 font-bold text-sm">{habit.current_streak}</span>
              </div>

              <%!-- XP reward --%>
              <div class="text-xs text-purple-400/60 shrink-0">
                +{habit.xp_reward} XP
              </div>

              <%!-- Actions --%>
              <div class="flex gap-1 shrink-0">
                <button
                  phx-click="delete_habit"
                  phx-value-id={habit.id}
                  data-confirm="Supprimer cette habitude ?"
                  class="p-1.5 text-white/20 hover:text-red-400 transition-colors"
                >
                  <.icon name="hero-trash" class="size-4" />
                </button>
              </div>
            </div>
          </div>
        </div>

        <%!-- Empty state --%>
        <div :if={@habits_with_status == []} class="text-center py-20">
          <div class="text-6xl mb-6">&#x1F504;</div>
          <p class="text-xl text-white/30 tracking-wider mb-6">Aucune habitude pour le moment</p>
          <button
            :if={!@show_new_form}
            phx-click="toggle_new_form"
            class="px-5 py-2.5 bg-purple-600 hover:bg-purple-700 text-white rounded-lg text-sm font-semibold shadow-lg shadow-purple-600/30 transition-all"
          >
            Creer une habitude
          </button>
        </div>
      </div>
    </div>
    """
  end

  # --- Events ---

  @impl true
  def handle_event("toggle_new_form", _, socket) do
    {:noreply,
     socket
     |> assign(:show_new_form, !socket.assigns.show_new_form)
     |> assign(:form, to_form(Habits.change_habit(%Habit{})))}
  end

  def handle_event("validate", %{"habit" => params}, socket) do
    changeset =
      %Habit{}
      |> Habits.change_habit(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  def handle_event("save", %{"habit" => params}, socket) do
    scope = socket.assigns.current_scope

    case Habits.create_habit(scope, params) do
      {:ok, _habit} ->
        {:noreply,
         socket
         |> put_flash(:info, "Habitude creee !")
         |> assign(:show_new_form, false)
         |> assign(:form, to_form(Habits.change_habit(%Habit{})))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def handle_event("complete_habit", %{"id" => id}, socket) do
    scope = socket.assigns.current_scope
    habit = Habits.get_habit!(scope, id)

    case Habits.complete_habit(scope, habit) do
      {:ok, _} -> {:noreply, socket}
      {:error, _} -> {:noreply, put_flash(socket, :error, "Erreur")}
    end
  end

  def handle_event("uncomplete_habit", %{"id" => id}, socket) do
    scope = socket.assigns.current_scope
    habit = Habits.get_habit!(scope, id)

    {:ok, _} = Habits.uncomplete_habit(scope, habit)
    {:noreply, socket}
  end

  def handle_event("delete_habit", %{"id" => id}, socket) do
    scope = socket.assigns.current_scope
    habit = Habits.get_habit!(scope, id)

    case Habits.delete_habit(scope, habit) do
      {:ok, _} -> {:noreply, put_flash(socket, :info, "Habitude supprimee")}
      {:error, _} -> {:noreply, put_flash(socket, :error, "Erreur")}
    end
  end

  # --- PubSub ---

  @impl true
  def handle_info({event, _}, socket)
      when event in [
             :habit_created,
             :habit_updated,
             :habit_deleted,
             :habit_completed,
             :habit_uncompleted
           ] do
    {:noreply, reload_data(socket)}
  end

  def handle_info({event, _}, socket) when event in [:xp_gained, :level_up, :streak_updated] do
    {:noreply, reload_profile(socket)}
  end

  def handle_info(_, socket), do: {:noreply, socket}

  defp reload_data(socket) do
    scope = socket.assigns.current_scope

    socket
    |> assign(:habits_with_status, Habits.list_habits_with_today_status(scope))
    |> assign(:heatmap, Habits.get_weekly_heatmap(scope))
    |> reload_profile()
  end

  defp reload_profile(socket) do
    scope = socket.assigns.current_scope
    profile = Gamification.get_or_create_profile(scope)

    socket
    |> assign(:profile, profile)
    |> assign(:xp_progress, Gamification.xp_progress_in_level(profile.xp))
  end

  defp day_label(date) do
    Calendar.strftime(date, "%a")
    |> String.slice(0..1)
  end
end
