defmodule ShdxwWeb.Components.AppNav do
  @moduledoc """
  Shared navigation component for all authenticated pages.
  """
  use Phoenix.Component
  use ShdxwWeb, :verified_routes

  import ShdxwWeb.CoreComponents, only: [icon: 1]

  attr :current_page, :atom, required: true
  attr :current_scope, :map, required: true

  def app_nav(assigns) do
    ~H"""
    <nav class="relative z-20 flex items-center justify-between px-6 py-3 border-b border-white/5 bg-black/80 backdrop-blur-sm">
      <div class="flex items-center gap-1">
        <.nav_link
          href={~p"/dashboard"}
          icon="hero-home"
          label="Dashboard"
          active={@current_page == :dashboard}
        />
        <.nav_link
          href={~p"/todos"}
          icon="hero-clipboard-document-list"
          label="Todos"
          active={@current_page == :todos}
        />
        <.nav_link
          href={~p"/habits"}
          icon="hero-arrow-path"
          label="Habitudes"
          active={@current_page == :habits}
        />
        <.nav_link
          href={~p"/pomodoro"}
          icon="hero-clock"
          label="Pomodoro"
          active={@current_page == :pomodoro}
        />
        <.nav_link
          href={~p"/shop"}
          icon="hero-shopping-bag"
          label="Boutique"
          active={@current_page == :shop}
        />
        <.nav_link
          href={~p"/achievements"}
          icon="hero-trophy"
          label="Succes"
          active={@current_page == :achievements}
        />
      </div>
      <div class="flex items-center gap-3">
        <span class="text-white text-xs hidden md:block">{@current_scope.user.email}</span>
        <a href={~p"/users/settings"} class="text-white/30 hover:text-white/60 transition-colors">
          <.icon name="hero-cog-6-tooth" class="size-4" />
        </a>
      </div>
    </nav>
    """
  end

  defp nav_link(assigns) do
    ~H"""
    <a
      href={@href}
      class={[
        "flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-semibold transition-all",
        @active && "bg-purple-600/20 text-purple-400 border border-purple-500/20",
        !@active && "text-white hover:text-purple-300 border border-transparent hover:bg-white/5"
      ]}
    >
      <.icon name={@icon} class="size-3.5" />
      <span>{@label}</span>
    </a>
    """
  end
end
