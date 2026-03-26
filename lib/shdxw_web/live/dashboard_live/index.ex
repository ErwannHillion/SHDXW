defmodule ShdxwWeb.DashboardLive.Index do
  use ShdxwWeb, :live_view

  alias Shdxw.Gamification
  alias Shdxw.DailyQuests
  alias Shdxw.Todos
  alias Shdxw.Pomodoro
  alias Shdxw.Skins
  alias Shdxw.Enchantments

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
    equipped_skin = Skins.get_equipped_skin(scope)
    enchantment_summary = Enchantments.get_enchantment_summary(scope)
    xp_multiplier = Gamification.get_xp_multiplier(scope)
    skin_xp = Skins.get_skin_xp_boost(scope)
    skin_gold = Skins.get_skin_gold_boost(scope)
    ench_xp = Enchantments.get_total_xp_boost(scope)
    ench_gold = Enchantments.get_total_gold_boost(scope)

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
     |> assign(:equipped_skin, equipped_skin)
     |> assign(:enchantment_summary, enchantment_summary)
     |> assign(:total_xp_boost, skin_xp + ench_xp)
     |> assign(:total_gold_boost, skin_gold + ench_gold)
     |> assign(:xp_multiplier, xp_multiplier)
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
        <%!-- Welcome + Mini Profile --%>
        <div class="flex items-start justify-between mb-10">
          <div>
            <h1 class="text-5xl font-black text-white tracking-wider mb-2">
              <span class="text-purple-500">Dash</span>board
            </h1>
            <div class="w-32 h-1 bg-gradient-to-r from-purple-500 to-transparent rounded-full mb-4" />
            <p class="text-white/40 text-sm">
              Niveau {@profile.level} — {@profile.title}
            </p>
          </div>

          <%!-- Mini Profile Card --%>
          <a href={~p"/profile"} class="hidden md:flex items-center gap-3 bg-gradient-to-br from-purple-950/40 to-black border border-purple-500/20 rounded-2xl px-5 py-3 hover:border-purple-500/40 transition-all group">
            <div class={[
              "w-12 h-12 rounded-full flex items-center justify-center text-xl border",
              if(@equipped_skin, do: skin_border_class(@equipped_skin.skin.rarity), else: "border-white/20 bg-white/5")
            ]}>
              {if @equipped_skin, do: @equipped_skin.skin.icon, else: "👤"}
            </div>
            <div>
              <div class="text-white font-bold text-sm group-hover:text-purple-300 transition-colors">{@profile.title}</div>
              <div class="flex items-center gap-2 text-xs">
                <span :if={@total_xp_boost > 0} class="text-purple-400">+{@total_xp_boost}% XP</span>
                <span :if={@total_gold_boost > 0} class="text-amber-400">+{@total_gold_boost}% Or</span>
                <span :if={@xp_multiplier > 1} class="text-cyan-400">x{@xp_multiplier} boost</span>
              </div>
            </div>
          </a>
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

        <%!-- Active Boosts Banner --%>
        <div :if={@total_xp_boost > 0 or @total_gold_boost > 0 or @xp_multiplier > 1}
          class="bg-gradient-to-r from-cyan-950/30 via-purple-950/30 to-amber-950/30 border border-cyan-500/20 rounded-2xl p-4 mb-8">
          <div class="flex items-center gap-2 mb-2">
            <span class="text-lg">🔮</span>
            <span class="text-white font-bold text-sm">Boosts actifs</span>
          </div>
          <div class="flex flex-wrap gap-3">
            <div :if={@xp_multiplier > 1} class="flex items-center gap-2 px-3 py-1.5 rounded-xl bg-cyan-600/20 border border-cyan-500/30">
              <span class="text-cyan-400 text-sm">⚡ Multiplicateur XP x{@xp_multiplier}</span>
            </div>
            <div :if={@total_xp_boost > 0} class="flex items-center gap-2 px-3 py-1.5 rounded-xl bg-purple-600/20 border border-purple-500/30">
              <span class="text-purple-400 text-sm">✨ +{@total_xp_boost}% XP permanent</span>
            </div>
            <div :if={@total_gold_boost > 0} class="flex items-center gap-2 px-3 py-1.5 rounded-xl bg-amber-600/20 border border-amber-500/30">
              <span class="text-amber-400 text-sm">💰 +{@total_gold_boost}% Or permanent</span>
            </div>
            <div :for={ench <- @enchantment_summary} class="flex items-center gap-2 px-3 py-1.5 rounded-xl bg-white/5 border border-white/10">
              <span class="text-white/60 text-sm">{ench.icon} {ench.name} {ench.roman}</span>
            </div>
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
              <span class="ml-auto text-xs text-emerald-400 font-normal">{quests_completed(@quests)}/{length(@quests)}</span>
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
                    FAIT ✓
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
        <div class="grid grid-cols-2 md:grid-cols-5 gap-4">
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
          <a
            href={~p"/korean"}
            class="bg-gradient-to-br from-rose-950/40 to-black border border-rose-500/20 rounded-2xl p-5 text-center hover:border-rose-500/40 hover:shadow-lg hover:shadow-rose-600/10 transition-all group"
          >
            <div class="text-3xl mb-2">&#x1F1F0;&#x1F1F7;</div>
            <div class="text-sm font-bold text-white/80 group-hover:text-white">Coreen</div>
            <div class="text-xs text-rose-400/60 mt-1">Apprendre le Hangul</div>
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
          <div class="w-px h-8 bg-white/10" />
          <div class="text-center">
            <div class="text-xs text-white/30 uppercase tracking-wider">Meilleur streak</div>
            <div class="text-xl font-black text-orange-400">{@profile.longest_streak}</div>
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
    |> assign(:equipped_skin, Skins.get_equipped_skin(scope))
    |> assign(:enchantment_summary, Enchantments.get_enchantment_summary(scope))
    |> assign(:total_xp_boost, Skins.get_skin_xp_boost(scope) + Enchantments.get_total_xp_boost(scope))
    |> assign(:total_gold_boost, Skins.get_skin_gold_boost(scope) + Enchantments.get_total_gold_boost(scope))
    |> assign(:xp_multiplier, Gamification.get_xp_multiplier(scope))
  end

  defp quest_percent(%{target_value: 0}), do: 0

  defp quest_percent(%{current_value: current, target_value: target}),
    do: round(min(current / target, 1) * 100)

  defp quests_completed(quests) do
    Enum.count(quests, fn q -> q.status == :completed end)
  end

  defp format_time(datetime) do
    Calendar.strftime(datetime, "%H:%M")
  end

  defp skin_border_class(rarity) do
    case rarity do
      :common -> "border-gray-400/50 bg-gray-900/50"
      :rare -> "border-blue-400/50 bg-blue-900/30"
      :epic -> "border-purple-400/50 bg-purple-900/30"
      :legendary -> "border-amber-400/50 bg-amber-900/30"
      :mythic -> "border-red-400/50 bg-red-900/30"
      _ -> "border-white/20 bg-white/5"
    end
  end
end
