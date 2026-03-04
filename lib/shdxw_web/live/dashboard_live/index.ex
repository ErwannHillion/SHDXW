defmodule ShdxwWeb.DashboardLive.Index do
  use ShdxwWeb, :live_view

  alias Shdxw.Gamification
  alias Shdxw.DailyQuests
  alias Shdxw.Todos
  alias Shdxw.Pomodoro

  import ShdxwWeb.Components.GamificationBar
  import ShdxwWeb.Components.AppNav

  @impl true
  def mount(_params, _session, socket) do
    scope = socket.assigns.current_scope

    if connected?(socket) do
      Gamification.subscribe(scope)
      DailyQuests.subscribe(scope)
    end

    profile = Gamification.get_or_create_profile(scope)
    quests = DailyQuests.get_or_generate_today_quests(scope)
    recent_events = Gamification.list_recent_events(scope, limit: 8)
    today_stats = Gamification.get_today_stats(scope)
    todo_stats = Todos.get_stats(scope)
    pomodoro_stats = Pomodoro.get_today_stats(scope)
    xp_progress = Gamification.xp_progress_in_level(profile.xp)

    {:ok,
     socket
     |> assign(:page_title, "Dashboard")
     |> assign(:profile, profile)
     |> assign(:quests, quests)
     |> assign(:recent_events, recent_events)
     |> assign(:today_stats, today_stats)
     |> assign(:todo_stats, todo_stats)
     |> assign(:pomodoro_stats, pomodoro_stats)
     |> assign(:xp_progress, xp_progress)
     |> assign(:current_page, :dashboard)}
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

      <Layouts.flash_group flash={@flash} />

      <div class="relative z-10 px-6 py-8 mx-auto max-w-6xl">
        <%!-- Welcome --%>
        <div class="mb-10">
          <h1 class="text-5xl font-black text-white tracking-wider mb-2">
            <span class="text-purple-500">Dash</span>board
          </h1>
          <div class="w-32 h-1 bg-gradient-to-r from-purple-500 to-transparent rounded-full mb-4" />
          <p class="text-white/40 text-sm">
            Niveau {@profile.level} — {@profile.title}
          </p>
        </div>

        <%!-- XP Progress Bar --%>
        <div class="bg-gradient-to-br from-purple-950/40 to-black border border-purple-500/20 rounded-2xl p-6 mb-8">
          <div class="flex items-center justify-between mb-3">
            <div class="flex items-center gap-3">
              <div class="w-14 h-14 rounded-full bg-gradient-to-br from-purple-600 to-violet-700 flex items-center justify-center text-white font-black text-xl shadow-lg shadow-purple-600/30 border border-purple-400/30">
                {@profile.level}
              </div>
              <div>
                <div class="text-white font-bold">Niveau {@profile.level}</div>
                <div class="text-white/40 text-sm">{@profile.title}</div>
              </div>
            </div>
            <div class="text-right">
              <div class="text-2xl font-black text-purple-400">{@profile.xp} XP</div>
              <div class="text-xs text-white/30">
                Niveau suivant: {Gamification.xp_for_level(@profile.level + 1)} XP
              </div>
            </div>
          </div>
          <div class="w-full h-4 bg-white/5 rounded-full overflow-hidden">
            <div
              class="h-full bg-gradient-to-r from-purple-600 to-violet-500 rounded-full transition-all duration-1000"
              style={"width: #{@xp_progress.percent}%"}
            />
          </div>
          <div class="flex justify-between text-xs text-white/30 mt-2">
            <span>{@xp_progress.current} / {@xp_progress.needed} XP</span>
            <span>{@xp_progress.percent}%</span>
          </div>
        </div>

        <%!-- Stats Grid --%>
        <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
          <div class="bg-gradient-to-br from-purple-950/40 to-black border border-purple-500/20 rounded-2xl p-5 text-center">
            <div class="text-3xl font-black text-amber-400">&#x2B50;</div>
            <div class="text-2xl font-black text-amber-400 mt-1">{@profile.gold}</div>
            <div class="text-xs text-white/40 tracking-wider uppercase mt-1">Or</div>
          </div>
          <div class="bg-gradient-to-br from-purple-950/40 to-black border border-purple-500/20 rounded-2xl p-5 text-center">
            <div class="text-3xl font-black text-orange-400">&#x1F525;</div>
            <div class="text-2xl font-black text-orange-400 mt-1">{@profile.current_streak}</div>
            <div class="text-xs text-white/40 tracking-wider uppercase mt-1">Streak (jours)</div>
          </div>
          <div class="bg-gradient-to-br from-purple-950/40 to-black border border-purple-500/20 rounded-2xl p-5 text-center">
            <div class="text-3xl font-black text-emerald-400">&#x2705;</div>
            <div class="text-2xl font-black text-emerald-400 mt-1">{@todo_stats.done}</div>
            <div class="text-xs text-white/40 tracking-wider uppercase mt-1">Taches terminees</div>
          </div>
          <div class="bg-gradient-to-br from-purple-950/40 to-black border border-purple-500/20 rounded-2xl p-5 text-center">
            <div class="text-3xl font-black text-blue-400">&#x23F1;</div>
            <div class="text-2xl font-black text-blue-400 mt-1">{@pomodoro_stats.sessions}</div>
            <div class="text-xs text-white/40 tracking-wider uppercase mt-1">
              Pomodoros aujourd'hui
            </div>
          </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
          <%!-- Daily Quests --%>
          <div class="bg-gradient-to-br from-purple-950/40 to-black border border-purple-500/20 rounded-2xl p-6">
            <h2 class="font-black text-white tracking-wider mb-4 flex items-center gap-2">
              <span class="text-xl">&#x2694;</span>
              <span>Quetes du <span class="text-purple-500">jour</span></span>
            </h2>
            <div class="space-y-3">
              <div
                :for={quest <- @quests}
                class={[
                  "border rounded-xl p-4 transition-all",
                  quest.status == :completed && "border-emerald-500/30 bg-emerald-500/5",
                  quest.status == :active && "border-white/10 bg-white/5"
                ]}
              >
                <div class="flex items-center justify-between mb-2">
                  <span class={[
                    "text-sm font-semibold",
                    quest.status == :completed && "text-emerald-400 line-through",
                    quest.status == :active && "text-white/80"
                  ]}>
                    {quest.description}
                  </span>
                  <span :if={quest.status == :completed} class="text-emerald-400 text-xs font-bold">
                    FAIT
                  </span>
                </div>
                <div class="w-full h-2 bg-white/5 rounded-full overflow-hidden">
                  <div
                    class={[
                      "h-full rounded-full transition-all duration-500",
                      quest.status == :completed && "bg-emerald-500",
                      quest.status == :active && "bg-purple-600"
                    ]}
                    style={"width: #{quest_percent(quest)}%"}
                  />
                </div>
                <div class="flex justify-between text-xs text-white/30 mt-1">
                  <span>{quest.current_value}/{quest.target_value}</span>
                  <span class="text-amber-400">+{quest.xp_reward} XP / +{quest.gold_reward} Or</span>
                </div>
              </div>
              <div :if={@quests == []} class="text-center py-8 text-white/20 text-sm">
                Aucune quete pour aujourd'hui
              </div>
            </div>
          </div>

          <%!-- Recent Activity --%>
          <div class="bg-gradient-to-br from-purple-950/40 to-black border border-purple-500/20 rounded-2xl p-6">
            <h2 class="font-black text-white tracking-wider mb-4 flex items-center gap-2">
              <span class="text-xl">&#x1F4DC;</span>
              <span>Activite <span class="text-purple-500">recente</span></span>
            </h2>
            <div class="space-y-2">
              <div
                :for={event <- @recent_events}
                class="flex items-center justify-between py-2 border-b border-white/5 last:border-0"
              >
                <div class="flex-1 min-w-0">
                  <span class="text-sm text-white/60 truncate block">{event.description}</span>
                  <span class="text-[10px] text-white/20">{format_time(event.inserted_at)}</span>
                </div>
                <div class="flex items-center gap-2 shrink-0 ml-3">
                  <span :if={event.xp_amount > 0} class="text-xs font-bold text-purple-400">
                    +{event.xp_amount} XP
                  </span>
                  <span :if={event.gold_amount > 0} class="text-xs font-bold text-amber-400">
                    +{event.gold_amount}
                  </span>
                </div>
              </div>
              <div :if={@recent_events == []} class="text-center py-8 text-white/20 text-sm">
                Aucune activite recente
              </div>
            </div>
          </div>
        </div>

        <%!-- Quick Actions --%>
        <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
          <a
            href={~p"/todos"}
            class="bg-gradient-to-br from-purple-950/40 to-black border border-purple-500/20 rounded-2xl p-5 text-center hover:border-purple-500/40 hover:shadow-lg hover:shadow-purple-600/10 transition-all group"
          >
            <div class="text-3xl mb-2">&#x1F4CB;</div>
            <div class="text-sm font-bold text-white/80 group-hover:text-white">Todos</div>
            <div class="text-xs text-white/30 mt-1">{@todo_stats.pending} en attente</div>
          </a>
          <a
            href={~p"/habits"}
            class="bg-gradient-to-br from-purple-950/40 to-black border border-purple-500/20 rounded-2xl p-5 text-center hover:border-purple-500/40 hover:shadow-lg hover:shadow-purple-600/10 transition-all group"
          >
            <div class="text-3xl mb-2">&#x1F504;</div>
            <div class="text-sm font-bold text-white/80 group-hover:text-white">Habitudes</div>
            <div class="text-xs text-white/30 mt-1">Quotidien</div>
          </a>
          <a
            href={~p"/pomodoro"}
            class="bg-gradient-to-br from-purple-950/40 to-black border border-purple-500/20 rounded-2xl p-5 text-center hover:border-purple-500/40 hover:shadow-lg hover:shadow-purple-600/10 transition-all group"
          >
            <div class="text-3xl mb-2">&#x23F1;</div>
            <div class="text-sm font-bold text-white/80 group-hover:text-white">Pomodoro</div>
            <div class="text-xs text-white/30 mt-1">
              {@pomodoro_stats.total_minutes} min aujourd'hui
            </div>
          </a>
          <a
            href={~p"/shop"}
            class="bg-gradient-to-br from-purple-950/40 to-black border border-purple-500/20 rounded-2xl p-5 text-center hover:border-purple-500/40 hover:shadow-lg hover:shadow-purple-600/10 transition-all group"
          >
            <div class="text-3xl mb-2">&#x1F6D2;</div>
            <div class="text-sm font-bold text-white/80 group-hover:text-white">Boutique</div>
            <div class="text-xs text-amber-400/60 mt-1">{@profile.gold} or disponible</div>
          </a>
        </div>

        <%!-- Today's XP/Gold Summary --%>
        <div class="mt-8 bg-gradient-to-r from-purple-950/30 to-black border border-purple-500/10 rounded-2xl p-4 flex items-center justify-center gap-8">
          <div class="text-center">
            <div class="text-xs text-white/30 uppercase tracking-wider">XP aujourd'hui</div>
            <div class="text-xl font-black text-purple-400">{@today_stats.xp_today}</div>
          </div>
          <div class="w-px h-8 bg-white/10" />
          <div class="text-center">
            <div class="text-xs text-white/30 uppercase tracking-wider">Or aujourd'hui</div>
            <div class="text-xl font-black text-amber-400">{@today_stats.gold_today}</div>
          </div>
          <div class="w-px h-8 bg-white/10" />
          <div class="text-center">
            <div class="text-xs text-white/30 uppercase tracking-wider">Total todos</div>
            <div class="text-xl font-black text-emerald-400">{@profile.total_todos_completed}</div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # --- PubSub ---

  @impl true
  def handle_info({event, _payload}, socket)
      when event in [:xp_gained, :level_up, :streak_updated, :gold_spent] do
    {:noreply, reload_data(socket)}
  end

  def handle_info({event, _payload}, socket)
      when event in [:quest_completed, :quest_progress] do
    scope = socket.assigns.current_scope
    quests = DailyQuests.get_or_generate_today_quests(scope)
    {:noreply, assign(socket, :quests, quests)}
  end

  def handle_info(_, socket), do: {:noreply, socket}

  defp reload_data(socket) do
    scope = socket.assigns.current_scope
    profile = Gamification.get_or_create_profile(scope)

    socket
    |> assign(:profile, profile)
    |> assign(:xp_progress, Gamification.xp_progress_in_level(profile.xp))
    |> assign(:today_stats, Gamification.get_today_stats(scope))
    |> assign(:recent_events, Gamification.list_recent_events(scope, limit: 8))
    |> assign(:todo_stats, Todos.get_stats(scope))
    |> assign(:pomodoro_stats, Pomodoro.get_today_stats(scope))
  end

  defp quest_percent(%{target_value: 0}), do: 0

  defp quest_percent(%{current_value: current, target_value: target}),
    do: round(min(current / target, 1) * 100)

  defp format_time(datetime) do
    Calendar.strftime(datetime, "%H:%M")
  end
end
