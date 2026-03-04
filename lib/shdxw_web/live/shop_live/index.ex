defmodule ShdxwWeb.ShopLive.Index do
  use ShdxwWeb, :live_view

  alias Shdxw.Shop
  alias Shdxw.Gamification

  import ShdxwWeb.Components.GamificationBar
  import ShdxwWeb.Components.AppNav

  @impl true
  def mount(_params, _session, socket) do
    scope = socket.assigns.current_scope

    if connected?(socket) do
      Shop.subscribe(scope)
      Gamification.subscribe(scope)
    end

    profile = Gamification.get_or_create_profile(scope)
    shop_items = Shop.list_items()
    user_items = Shop.list_user_items(scope)
    active_boosts = Shop.list_active_boosts(scope)

    {:ok,
     socket
     |> assign(:page_title, "Boutique")
     |> assign(:profile, profile)
     |> assign(:xp_progress, Gamification.xp_progress_in_level(profile.xp))
     |> assign(:shop_items, shop_items)
     |> assign(:user_items, user_items)
     |> assign(:active_boosts, active_boosts)
     |> assign(:tab, :all)
     |> assign(:current_page, :shop)}
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
            <span class="text-purple-500">Bou</span>tique
          </h1>
          <div class="w-32 h-1 bg-gradient-to-r from-purple-500 to-transparent rounded-full mb-4" />
          <div class="flex items-center gap-2">
            <span class="text-amber-400 text-lg">&#x2B50;</span>
            <span class="text-amber-400 font-black text-2xl">{@profile.gold}</span>
            <span class="text-white/30 text-sm ml-1">or disponible</span>
          </div>
        </div>

        <%!-- Active Boosts --%>
        <div :if={@active_boosts != []} class="mb-8">
          <h3 class="text-xs text-white/40 tracking-wider uppercase mb-3">Boosts actifs</h3>
          <div class="flex flex-wrap gap-3">
            <div
              :for={boost <- @active_boosts}
              class="bg-purple-600/20 border border-purple-500/30 rounded-xl px-4 py-2 flex items-center gap-2"
            >
              <span class="text-purple-400 font-bold text-sm">{boost.shop_item.name}</span>
              <span :if={boost.expires_at} class="text-xs text-white/30">
                expire {format_expiry(boost.expires_at)}
              </span>
            </div>
          </div>
        </div>

        <%!-- Tabs --%>
        <div class="flex gap-2 mb-8">
          <button
            :for={{label, value} <- shop_tabs()}
            phx-click="switch_tab"
            phx-value-tab={value}
            class={[
              "px-4 py-2 rounded-lg text-sm font-semibold transition-all",
              @tab == value && "bg-purple-600/20 text-purple-400 border border-purple-500/20",
              @tab != value && "text-white/40 hover:text-white/60 border border-transparent"
            ]}
          >
            {label}
          </button>
        </div>

        <%!-- Shop Items Grid --%>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 mb-12">
          <div
            :for={item <- filtered_items(@shop_items, @tab)}
            class={[
              "bg-gradient-to-br from-purple-950/30 to-black border-2 rounded-2xl p-5 transition-all hover:shadow-lg",
              rarity_border(item.rarity),
              rarity_shadow(item.rarity)
            ]}
          >
            <div class="flex items-start justify-between mb-3">
              <div>
                <span class={[
                  "text-[10px] font-bold tracking-wider uppercase px-2 py-0.5 rounded-full",
                  rarity_pill(item.rarity)
                ]}>
                  {rarity_label(item.rarity)}
                </span>
              </div>
              <div class="text-right">
                <div class="flex items-center gap-1">
                  <span class="text-amber-400">&#x2B50;</span>
                  <span class="text-amber-400 font-black text-lg">{item.price}</span>
                </div>
              </div>
            </div>

            <h3 class="text-lg font-black text-white mb-1">{item.name}</h3>
            <p class="text-sm text-white/40 mb-3">{item.description}</p>

            <div class="flex items-center gap-2 text-xs text-white/30 mb-4">
              <span :if={item.duration_minutes} class="flex items-center gap-1">
                <.icon name="hero-clock" class="size-3" /> {item.duration_minutes} min
              </span>
              <span :if={item.level_required > 1} class="flex items-center gap-1">
                <.icon name="hero-star" class="size-3" /> Niveau {item.level_required}
              </span>
              <span class="px-2 py-0.5 rounded-full bg-white/5">
                {type_label(item.type)}
              </span>
            </div>

            <button
              phx-click="purchase"
              phx-value-id={item.id}
              disabled={@profile.gold < item.price or @profile.level < item.level_required}
              class={[
                "w-full py-2.5 rounded-xl text-sm font-bold transition-all",
                @profile.gold >= item.price && @profile.level >= item.level_required &&
                  "bg-purple-600 hover:bg-purple-700 text-white shadow-lg shadow-purple-600/30",
                (@profile.gold < item.price || @profile.level < item.level_required) &&
                  "bg-white/5 text-white/20 cursor-not-allowed"
              ]}
            >
              <%= cond do %>
                <% @profile.level < item.level_required -> %>
                  Niveau {item.level_required} requis
                <% @profile.gold < item.price -> %>
                  Or insuffisant
                <% true -> %>
                  Acheter
              <% end %>
            </button>
          </div>
        </div>

        <%!-- Inventory --%>
        <div
          :if={@user_items != []}
          class="bg-gradient-to-br from-purple-950/40 to-black border border-purple-500/20 rounded-2xl p-6"
        >
          <h2 class="font-black text-white tracking-wider mb-4">
            <span class="text-purple-500">Inven</span>taire
          </h2>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-3">
            <div
              :for={user_item <- @user_items}
              class="border border-white/10 rounded-xl p-4 flex items-center justify-between"
            >
              <div>
                <span class="font-semibold text-white/80">{user_item.shop_item.name}</span>
                <span class="text-xs text-white/30 ml-2">x{user_item.quantity}</span>
              </div>
              <button
                :if={user_item.quantity > 0 && user_item.shop_item.type in [:boost, :consumable]}
                phx-click="activate"
                phx-value-id={user_item.id}
                class="px-3 py-1.5 bg-purple-600/20 hover:bg-purple-600/30 text-purple-400 rounded-lg text-xs font-bold transition-all border border-purple-500/20"
              >
                Utiliser
              </button>
            </div>
          </div>
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

  def handle_event("purchase", %{"id" => id}, socket) do
    scope = socket.assigns.current_scope

    case Shop.purchase_item(scope, String.to_integer(id)) do
      {:ok, _} ->
        {:noreply, put_flash(socket, :info, "Achat effectue !")}

      {:error, :insufficient_gold} ->
        {:noreply, put_flash(socket, :error, "Or insuffisant !")}

      {:error, :level_required} ->
        {:noreply, put_flash(socket, :error, "Niveau insuffisant !")}

      {:error, :max_owned} ->
        {:noreply, put_flash(socket, :error, "Quantite maximum atteinte !")}
    end
  end

  def handle_event("activate", %{"id" => id}, socket) do
    scope = socket.assigns.current_scope

    case Shop.activate_item(scope, String.to_integer(id)) do
      {:ok, _} ->
        {:noreply, put_flash(socket, :info, "Item active !")}

      {:error, :no_items} ->
        {:noreply, put_flash(socket, :error, "Plus d'items disponibles")}
    end
  end

  # --- PubSub ---

  @impl true
  def handle_info({event, _}, socket)
      when event in [:item_purchased, :item_activated] do
    {:noreply, reload_data(socket)}
  end

  def handle_info({event, _}, socket)
      when event in [:xp_gained, :level_up, :gold_spent, :streak_updated] do
    {:noreply, reload_profile(socket)}
  end

  def handle_info(_, socket), do: {:noreply, socket}

  defp reload_data(socket) do
    scope = socket.assigns.current_scope

    socket
    |> assign(:shop_items, Shop.list_items())
    |> assign(:user_items, Shop.list_user_items(scope))
    |> assign(:active_boosts, Shop.list_active_boosts(scope))
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

  defp shop_tabs do
    [
      {"Tout", :all},
      {"Boosts", :boost},
      {"Consommables", :consumable},
      {"Cosmetiques", :cosmetic}
    ]
  end

  defp filtered_items(items, :all), do: items
  defp filtered_items(items, type), do: Enum.filter(items, &(&1.type == type))

  defp rarity_border(:common), do: "border-white/10"
  defp rarity_border(:rare), do: "border-blue-500/30"
  defp rarity_border(:epic), do: "border-purple-500/30"
  defp rarity_border(:legendary), do: "border-amber-500/30"

  defp rarity_shadow(:common), do: ""
  defp rarity_shadow(:rare), do: "hover:shadow-blue-600/10"
  defp rarity_shadow(:epic), do: "hover:shadow-purple-600/10"
  defp rarity_shadow(:legendary), do: "hover:shadow-amber-600/10"

  defp rarity_pill(:common), do: "bg-white/10 text-white/40"
  defp rarity_pill(:rare), do: "bg-blue-400/10 text-blue-400"
  defp rarity_pill(:epic), do: "bg-purple-400/10 text-purple-400"
  defp rarity_pill(:legendary), do: "bg-amber-400/10 text-amber-400"

  defp rarity_label(:common), do: "Commun"
  defp rarity_label(:rare), do: "Rare"
  defp rarity_label(:epic), do: "Epique"
  defp rarity_label(:legendary), do: "Legendaire"

  defp type_label(:boost), do: "Boost"
  defp type_label(:consumable), do: "Consommable"
  defp type_label(:cosmetic), do: "Cosmetique"
  defp type_label(:special), do: "Special"

  defp format_expiry(nil), do: ""

  defp format_expiry(datetime) do
    diff = DateTime.diff(datetime, DateTime.utc_now(), :minute)

    cond do
      diff <= 0 -> "expire"
      diff < 60 -> "dans #{diff}min"
      true -> "dans #{div(diff, 60)}h"
    end
  end
end
