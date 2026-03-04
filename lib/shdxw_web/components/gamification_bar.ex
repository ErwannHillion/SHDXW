defmodule ShdxwWeb.Components.GamificationBar do
  @moduledoc """
  Gamification bar component showing XP, level, gold, and streak.
  Displayed on all authenticated pages.
  """
  use Phoenix.Component

  attr :profile, :map, required: true
  attr :xp_progress, :map, required: true

  def gamification_bar(assigns) do
    ~H"""
    <div class="relative z-20 flex items-center gap-4 px-4 py-2 bg-gradient-to-r from-purple-950/80 to-black/80 backdrop-blur-sm border-b border-purple-500/10">
      <%!-- Level badge --%>
      <div class="flex items-center gap-2">
        <div class="w-10 h-10 rounded-full bg-gradient-to-br from-purple-600 to-violet-700 flex items-center justify-center text-white font-black text-sm shadow-lg shadow-purple-600/30 border border-purple-400/30">
          {@profile.level}
        </div>
        <div class="hidden sm:block">
          <div class="text-[10px] text-white/40 uppercase tracking-wider">{@profile.title}</div>
          <div class="w-28 h-1.5 bg-white/5 rounded-full overflow-hidden mt-0.5">
            <div
              class="h-full bg-gradient-to-r from-purple-600 to-violet-500 rounded-full transition-all duration-1000"
              style={"width: #{@xp_progress.percent}%"}
            />
          </div>
          <div class="text-[9px] text-white/20 mt-0.5">
            {@xp_progress.current}/{@xp_progress.needed} XP
          </div>
        </div>
      </div>

      <div class="flex-1" />

      <%!-- Gold --%>
      <div class="flex items-center gap-1.5 bg-amber-400/5 border border-amber-400/10 rounded-xl px-3 py-1.5">
        <span class="text-amber-400 text-sm">&#x2B50;</span>
        <span class="text-amber-400 font-bold text-sm">{@profile.gold}</span>
      </div>

      <%!-- Streak --%>
      <div class="flex items-center gap-1.5 bg-orange-400/5 border border-orange-400/10 rounded-xl px-3 py-1.5">
        <span class="text-orange-400 text-sm">&#x1F525;</span>
        <span class="text-orange-400 font-bold text-sm">{@profile.current_streak}j</span>
      </div>
    </div>
    """
  end
end
