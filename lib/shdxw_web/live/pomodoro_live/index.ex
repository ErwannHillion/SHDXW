defmodule ShdxwWeb.PomodoroLive.Index do
  use ShdxwWeb, :live_view

  alias Shdxw.Pomodoro
  alias Shdxw.Gamification
  alias Shdxw.Todos

  import ShdxwWeb.Components.GamificationBar
  import ShdxwWeb.Components.AppNav

  @impl true
  def mount(_params, _session, socket) do
    scope = socket.assigns.current_scope

    if connected?(socket) do
      Pomodoro.subscribe(scope)
      Gamification.subscribe(scope)
    end

    profile = Gamification.get_or_create_profile(scope)
    active_session = Pomodoro.get_active_session(scope)
    today_sessions = Pomodoro.list_today_sessions(scope)
    today_stats = Pomodoro.get_today_stats(scope)

    todos =
      Todos.list_todos(scope, status: :in_progress) ++ Todos.list_todos(scope, status: :pending)

    {:ok,
     socket
     |> assign(:page_title, "Pomodoro")
     |> assign(:profile, profile)
     |> assign(:xp_progress, Gamification.xp_progress_in_level(profile.xp))
     |> assign(:active_session, active_session)
     |> assign(:today_sessions, today_sessions)
     |> assign(:today_stats, today_stats)
     |> assign(:todos, todos)
     |> assign(:selected_duration, 25)
     |> assign(:selected_todo_id, nil)
     |> assign(:remaining_seconds, compute_remaining(active_session))
     |> assign(:current_page, :pomodoro)}
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
            <span class="text-purple-500">Pomo</span>doro
          </h1>
          <div class="w-32 h-1 bg-gradient-to-r from-purple-500 to-transparent rounded-full" />
        </div>

        <%!-- Timer --%>
        <div class="flex flex-col items-center mb-12">
          <div
            id="pomodoro-timer"
            phx-hook="PomodoroTimer"
            data-active={if @active_session, do: "true", else: "false"}
            data-remaining={@remaining_seconds}
            class="relative w-64 h-64 mb-8"
          >
            <%!-- Background circle --%>
            <svg class="w-full h-full -rotate-90" viewBox="0 0 100 100">
              <circle
                cx="50"
                cy="50"
                r="45"
                fill="none"
                stroke="rgba(255,255,255,0.05)"
                stroke-width="4"
              />
              <circle
                cx="50"
                cy="50"
                r="45"
                fill="none"
                stroke="url(#gradient)"
                stroke-width="4"
                stroke-linecap="round"
                stroke-dasharray={Float.to_string(2 * :math.pi() * 45)}
                stroke-dashoffset={Float.to_string(timer_offset(@active_session, @remaining_seconds))}
                class="transition-all duration-1000"
              />
              <defs>
                <linearGradient id="gradient" x1="0%" y1="0%" x2="100%" y2="0%">
                  <stop offset="0%" stop-color="#9333ea" />
                  <stop offset="100%" stop-color="#7c3aed" />
                </linearGradient>
              </defs>
            </svg>
            <%!-- Timer text --%>
            <div class="absolute inset-0 flex flex-col items-center justify-center">
              <div class="text-5xl font-black text-white tracking-wider" id="timer-display">
                {format_time(@remaining_seconds)}
              </div>
              <div
                :if={@active_session}
                class="text-xs text-purple-400/60 mt-2 uppercase tracking-wider"
              >
                En cours
              </div>
              <div :if={!@active_session} class="text-xs text-white/30 mt-2 uppercase tracking-wider">
                Pret
              </div>
            </div>
          </div>

          <%!-- Controls --%>
          <div :if={!@active_session} class="space-y-6 text-center">
            <%!-- Duration selector --%>
            <div class="flex gap-3 justify-center">
              <button
                :for={duration <- [25, 45, 60]}
                phx-click="select_duration"
                phx-value-duration={duration}
                class={[
                  "px-5 py-2.5 rounded-xl text-sm font-bold transition-all",
                  @selected_duration == duration &&
                    "bg-purple-600 text-white shadow-lg shadow-purple-600/30",
                  @selected_duration != duration &&
                    "bg-white/5 text-white/40 border border-white/10 hover:border-purple-500/30"
                ]}
              >
                {duration} min
              </button>
            </div>

            <%!-- Todo selector --%>
            <div :if={@todos != []} class="max-w-xs mx-auto">
              <label class="text-xs text-white/40 tracking-wider uppercase mb-1 block text-center">
                Lier a une tache (optionnel)
              </label>
              <select
                phx-change="select_todo"
                name="todo_id"
                class="w-full bg-white/5 border border-white/10 focus:border-purple-500/50 rounded-lg px-4 py-2.5 text-white text-sm outline-none transition-all"
              >
                <option value="">Aucune</option>
                <option :for={todo <- @todos} value={todo.id} selected={@selected_todo_id == todo.id}>
                  {todo.title}
                </option>
              </select>
            </div>

            <%!-- XP Preview --%>
            <div class="text-xs text-white/30">
              <% {xp, gold} = Pomodoro.xp_for_duration(@selected_duration) %> Recompense:
              <span class="text-purple-400 font-bold">+{xp} XP</span>
              / <span class="text-amber-400 font-bold">+{gold} Or</span>
            </div>

            <%!-- Start button --%>
            <button
              phx-click="start"
              class="px-8 py-3 bg-purple-600 hover:bg-purple-700 text-white rounded-xl text-lg font-black shadow-lg shadow-purple-600/30 hover:shadow-purple-600/50 transition-all tracking-wider"
            >
              DEMARRER
            </button>
          </div>

          <%!-- Active controls --%>
          <div :if={@active_session} class="text-center">
            <button
              phx-click="cancel"
              class="px-6 py-2.5 bg-red-600/20 hover:bg-red-600/30 text-red-400 border border-red-500/20 rounded-xl text-sm font-semibold transition-all"
            >
              Annuler
            </button>
          </div>
        </div>

        <%!-- Today stats --%>
        <div class="grid grid-cols-2 gap-4 mb-8">
          <div class="bg-gradient-to-br from-purple-950/40 to-black border border-purple-500/20 rounded-2xl p-5 text-center">
            <div class="text-3xl font-black text-purple-400">{@today_stats.sessions}</div>
            <div class="text-xs text-white/40 tracking-wider uppercase mt-1">Sessions</div>
          </div>
          <div class="bg-gradient-to-br from-purple-950/40 to-black border border-purple-500/20 rounded-2xl p-5 text-center">
            <div class="text-3xl font-black text-blue-400">{@today_stats.total_minutes}</div>
            <div class="text-xs text-white/40 tracking-wider uppercase mt-1">Minutes de focus</div>
          </div>
        </div>

        <%!-- Session History --%>
        <div
          :if={@today_sessions != []}
          class="bg-gradient-to-br from-purple-950/40 to-black border border-purple-500/20 rounded-2xl p-6"
        >
          <h3 class="font-black text-white tracking-wider mb-4">
            Historique du <span class="text-purple-500">jour</span>
          </h3>
          <div class="space-y-2">
            <div
              :for={session <- @today_sessions}
              class="flex items-center justify-between py-2 border-b border-white/5 last:border-0"
            >
              <div class="flex items-center gap-3">
                <div class={[
                  "w-8 h-8 rounded-lg flex items-center justify-center text-xs",
                  session.status == :completed && "bg-emerald-500/20 text-emerald-400",
                  session.status == :cancelled && "bg-red-500/20 text-red-400",
                  session.status == :in_progress && "bg-blue-500/20 text-blue-400"
                ]}>
                  <.icon name={session_icon(session.status)} class="size-4" />
                </div>
                <div>
                  <span class="text-sm text-white/70">{session.duration_minutes} min</span>
                  <span class="text-xs text-white/30 ml-2">
                    {Calendar.strftime(session.started_at, "%H:%M")}
                  </span>
                </div>
              </div>
              <div :if={session.status == :completed} class="flex items-center gap-2">
                <span class="text-xs font-bold text-purple-400">+{session.xp_earned} XP</span>
                <span class="text-xs font-bold text-amber-400">+{session.gold_earned}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # --- Events ---

  @impl true
  def handle_event("select_duration", %{"duration" => duration}, socket) do
    duration = String.to_integer(duration)

    {:noreply,
     assign(socket, :selected_duration, duration) |> assign(:remaining_seconds, duration * 60)}
  end

  def handle_event("select_todo", %{"todo_id" => ""}, socket) do
    {:noreply, assign(socket, :selected_todo_id, nil)}
  end

  def handle_event("select_todo", %{"todo_id" => id}, socket) do
    {:noreply, assign(socket, :selected_todo_id, String.to_integer(id))}
  end

  def handle_event("start", _, socket) do
    scope = socket.assigns.current_scope

    attrs = %{
      duration_minutes: socket.assigns.selected_duration,
      todo_id: socket.assigns.selected_todo_id
    }

    case Pomodoro.start_session(scope, attrs) do
      {:ok, session} ->
        remaining = session.duration_minutes * 60

        {:noreply,
         socket
         |> assign(:active_session, session)
         |> assign(:remaining_seconds, remaining)
         |> push_event("start_timer", %{duration_seconds: remaining})}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Erreur au demarrage")}
    end
  end

  def handle_event("cancel", _, socket) do
    scope = socket.assigns.current_scope

    if socket.assigns.active_session do
      Pomodoro.cancel_session(scope, socket.assigns.active_session)
    end

    {:noreply,
     socket
     |> assign(:active_session, nil)
     |> assign(:remaining_seconds, socket.assigns.selected_duration * 60)
     |> push_event("stop_timer", %{})}
  end

  def handle_event("timer_tick", %{"remaining_seconds" => seconds}, socket) do
    {:noreply, assign(socket, :remaining_seconds, seconds)}
  end

  def handle_event("timer_complete", _, socket) do
    scope = socket.assigns.current_scope
    session = socket.assigns.active_session

    if session do
      # Reload session from DB to get fresh data
      session = Pomodoro.get_session!(scope, session.id)

      case Pomodoro.complete_session(scope, session) do
        {:ok, _completed} ->
          {:noreply,
           socket
           |> assign(:active_session, nil)
           |> assign(:remaining_seconds, 0)
           |> put_flash(:info, "Pomodoro termine ! XP et or gagnes !")}

        {:error, _} ->
          {:noreply, put_flash(socket, :error, "Erreur lors de la completion")}
      end
    else
      {:noreply, socket}
    end
  end

  # --- PubSub ---

  @impl true
  def handle_info({event, _}, socket)
      when event in [:pomodoro_started, :pomodoro_completed, :pomodoro_cancelled] do
    {:noreply, reload_data(socket)}
  end

  def handle_info({event, _}, socket) when event in [:xp_gained, :level_up, :streak_updated] do
    {:noreply, reload_profile(socket)}
  end

  def handle_info(_, socket), do: {:noreply, socket}

  defp reload_data(socket) do
    scope = socket.assigns.current_scope

    socket
    |> assign(:today_sessions, Pomodoro.list_today_sessions(scope))
    |> assign(:today_stats, Pomodoro.get_today_stats(scope))
    |> reload_profile()
  end

  defp reload_profile(socket) do
    scope = socket.assigns.current_scope
    profile = Gamification.get_or_create_profile(scope)

    socket
    |> assign(:profile, profile)
    |> assign(:xp_progress, Gamification.xp_progress_in_level(profile.xp))
  end

  # --- Helpers ---

  defp compute_remaining(nil), do: 25 * 60

  defp compute_remaining(session) do
    elapsed = DateTime.diff(DateTime.utc_now(), session.started_at, :second)
    max(session.duration_minutes * 60 - elapsed, 0)
  end

  defp format_time(seconds) when seconds <= 0, do: "00:00"

  defp format_time(seconds) do
    minutes = div(seconds, 60)
    secs = rem(seconds, 60)

    "#{String.pad_leading(to_string(minutes), 2, "0")}:#{String.pad_leading(to_string(secs), 2, "0")}"
  end

  defp timer_offset(nil, _), do: 2 * :math.pi() * 45

  defp timer_offset(session, remaining) do
    total = session.duration_minutes * 60
    progress = if total > 0, do: remaining / total, else: 1
    2 * :math.pi() * 45 * progress
  end

  defp session_icon(:completed), do: "hero-check-circle-solid"
  defp session_icon(:cancelled), do: "hero-x-circle"
  defp session_icon(:in_progress), do: "hero-play"
end
