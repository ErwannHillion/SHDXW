defmodule ShdxwWeb.AchievementsLive.Index do
  use ShdxwWeb, :live_view

  alias Shdxw.Achievements
  alias Shdxw.Gamification

  import ShdxwWeb.Components.GamificationBar
  import ShdxwWeb.Components.AppNav

  @impl true
  def mount(_params, _session, socket) do
    scope = socket.assigns.current_scope

    if connected?(socket) do
      Achievements.subscribe(scope)
      Gamification.subscribe(scope)
    end

    profile = Gamification.get_or_create_profile(scope)
    all_achievements = Achievements.list_all_achievements()
    unlocked_ids = Achievements.unlocked_achievement_ids(scope)
    unlocked_count = Achievements.count_unlocked(scope)

    {:ok,
     socket
     |> assign(:page_title, "Succes")
     |> assign(:profile, profile)
     |> assign(:xp_progress, Gamification.xp_progress_in_level(profile.xp))
     |> assign(:all_achievements, all_achievements)
     |> assign(:unlocked_ids, unlocked_ids)
     |> assign(:unlocked_count, unlocked_count)
     |> assign(:total_count, length(all_achievements))
     |> assign(:tab, :all)
     |> assign(:current_page, :achievements)}
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

      <div class="relative z-10 px-6 py-8 mx-auto max-w-6xl">
        <div class="mb-10">
          <h1 class="text-5xl font-black text-white tracking-wider mb-2">
            <span class="text-purple-500">Suc</span>ces
          </h1>
          <div class="w-32 h-1 bg-gradient-to-r from-purple-500 to-transparent rounded-full mb-4" />
          <p class="text-white/40 text-sm">
            {@unlocked_count}/{@total_count} debloques
          </p>
          <%!-- Progress bar --%>
          <div class="w-64 h-2 bg-white/5 rounded-full overflow-hidden mt-2">
            <div
              class="h-full bg-gradient-to-r from-purple-600 to-violet-500 rounded-full transition-all"
              style={"width: #{if @total_count > 0, do: round(@unlocked_count / @total_count * 100), else: 0}%"}
            />
          </div>
        </div>

        <%!-- Category Tabs --%>
        <div class="flex flex-wrap gap-2 mb-8">
          <button
            :for={{label, value} <- category_tabs()}
            phx-click="switch_tab"
            phx-value-tab={value}
            class={[
              "px-3 py-1.5 rounded-lg text-xs font-semibold transition-all",
              @tab == value && "bg-purple-600/20 text-purple-400 border border-purple-500/20",
              @tab != value && "text-white/40 hover:text-white/60 border border-transparent"
            ]}
          >
            {label}
          </button>
        </div>

        <%!-- Achievements Grid --%>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          <div
            :for={achievement <- filtered_achievements(@all_achievements, @tab)}
            class={[
              "border-2 rounded-2xl p-5 transition-all",
              unlocked?(achievement, @unlocked_ids) && "bg-gradient-to-br from-purple-950/40 to-black",
              unlocked?(achievement, @unlocked_ids) && rarity_border(achievement.rarity),
              !unlocked?(achievement, @unlocked_ids) && "bg-black/40 border-white/5 opacity-60"
            ]}
          >
            <div class="flex items-start justify-between mb-3">
              <div class={[
                "w-12 h-12 rounded-xl flex items-center justify-center text-2xl",
                unlocked?(achievement, @unlocked_ids) && rarity_bg(achievement.rarity),
                !unlocked?(achievement, @unlocked_ids) && "bg-white/5"
              ]}>
                <%= if achievement.hidden && !unlocked?(achievement, @unlocked_ids) do %>
                  <span class="text-white/20">?</span>
                <% else %>
                  <span>{achievement_icon(achievement.category)}</span>
                <% end %>
              </div>
              <span class={[
                "text-[10px] font-bold tracking-wider uppercase px-2 py-0.5 rounded-full",
                rarity_pill(achievement.rarity)
              ]}>
                {rarity_label(achievement.rarity)}
              </span>
            </div>

            <%= if achievement.hidden && !unlocked?(achievement, @unlocked_ids) do %>
              <h3 class="font-black text-white/30 mb-1">???</h3>
              <p class="text-sm text-white/20">Succes secret</p>
            <% else %>
              <h3 class={[
                "font-black mb-1",
                unlocked?(achievement, @unlocked_ids) && "text-white",
                !unlocked?(achievement, @unlocked_ids) && "text-white/50"
              ]}>
                {achievement.name}
              </h3>
              <p class="text-sm text-white/30 mb-3">{achievement.description}</p>

              <%!-- Progress bar for locked achievements --%>
              <div :if={!unlocked?(achievement, @unlocked_ids)}>
                <% {current, target} = get_progress(achievement, @current_scope) %>
                <div class="w-full h-1.5 bg-white/5 rounded-full overflow-hidden mb-1">
                  <div
                    class="h-full bg-white/20 rounded-full"
                    style={"width: #{if target > 0, do: round(min(current / target, 1) * 100), else: 0}%"}
                  />
                </div>
                <div class="text-[10px] text-white/20">{current}/{target}</div>
              </div>

              <%!-- Rewards --%>
              <div :if={unlocked?(achievement, @unlocked_ids)} class="flex items-center gap-2 mt-2">
                <span :if={achievement.xp_reward > 0} class="text-xs font-bold text-purple-400">
                  +{achievement.xp_reward} XP
                </span>
                <span :if={achievement.gold_reward > 0} class="text-xs font-bold text-amber-400">
                  +{achievement.gold_reward} Or
                </span>
                <span class="text-xs text-emerald-400 ml-auto">&#x2705; Debloque</span>
              </div>
            <% end %>
          </div>
        </div>

        <div :if={filtered_achievements(@all_achievements, @tab) == []} class="text-center py-20">
          <div class="text-6xl mb-6">&#x1F3C6;</div>
          <p class="text-xl text-white/30 tracking-wider">Aucun succes dans cette categorie</p>
        </div>
      </div>
    </div>
    """
  end

  # --- Events ---

  @impl true
  def handle_event("switch_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, :tab, String.to_existing_atom(tab))}
  end

  # --- PubSub ---

  @impl true
  def handle_info({:achievement_unlocked, _}, socket) do
    {:noreply, reload_data(socket)}
  end

  def handle_info({event, _}, socket) when event in [:xp_gained, :level_up, :streak_updated] do
    {:noreply, reload_profile(socket)}
  end

  def handle_info(_, socket), do: {:noreply, socket}

  defp reload_data(socket) do
    scope = socket.assigns.current_scope

    socket
    |> assign(:all_achievements, Achievements.list_all_achievements())
    |> assign(:unlocked_ids, Achievements.unlocked_achievement_ids(scope))
    |> assign(:unlocked_count, Achievements.count_unlocked(scope))
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

  defp category_tabs do
    [
      {"Tout", :all},
      {"Todos", :todos},
      {"Habitudes", :habits},
      {"Pomodoro", :pomodoro},
      {"Streak", :streak},
      {"Niveau", :level},
      {"Boutique", :shop},
      {"Secret", :secret}
    ]
  end

  defp filtered_achievements(achievements, :all), do: achievements

  defp filtered_achievements(achievements, category),
    do: Enum.filter(achievements, &(&1.category == category))

  defp unlocked?(achievement, unlocked_ids), do: MapSet.member?(unlocked_ids, achievement.id)

  defp get_progress(achievement, scope) do
    Achievements.get_progress(scope, achievement)
  end

  defp rarity_border(:common), do: "border-white/20"
  defp rarity_border(:rare), do: "border-blue-500/30"
  defp rarity_border(:epic), do: "border-purple-500/30"
  defp rarity_border(:legendary), do: "border-amber-500/40"

  defp rarity_bg(:common), do: "bg-white/10"
  defp rarity_bg(:rare), do: "bg-blue-500/20"
  defp rarity_bg(:epic), do: "bg-purple-500/20"
  defp rarity_bg(:legendary), do: "bg-amber-500/20"

  defp rarity_pill(:common), do: "bg-white/10 text-white/40"
  defp rarity_pill(:rare), do: "bg-blue-400/10 text-blue-400"
  defp rarity_pill(:epic), do: "bg-purple-400/10 text-purple-400"
  defp rarity_pill(:legendary), do: "bg-amber-400/10 text-amber-400"

  defp rarity_label(:common), do: "Commun"
  defp rarity_label(:rare), do: "Rare"
  defp rarity_label(:epic), do: "Epique"
  defp rarity_label(:legendary), do: "Legendaire"

  defp achievement_icon(:todos), do: "\u{1F4CB}"
  defp achievement_icon(:habits), do: "\u{1F504}"
  defp achievement_icon(:pomodoro), do: "\u{23F1}"
  defp achievement_icon(:streak), do: "\u{1F525}"
  defp achievement_icon(:level), do: "\u{2B50}"
  defp achievement_icon(:shop), do: "\u{1F6D2}"
  defp achievement_icon(:secret), do: "\u{1F47E}"
end
