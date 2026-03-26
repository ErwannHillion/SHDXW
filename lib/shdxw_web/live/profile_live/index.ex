defmodule ShdxwWeb.ProfileLive.Index do
  use ShdxwWeb, :live_view

  alias Shdxw.Gamification
  alias Shdxw.Skins
  alias Shdxw.Enchantments

  import ShdxwWeb.Components.GamificationBar
  import ShdxwWeb.Components.AppNav

  @impl true
  def mount(_params, _session, socket) do
    scope = socket.assigns.current_scope

    if connected?(socket) do
      Gamification.subscribe(scope)
    end

    profile = Gamification.get_or_create_profile(scope)
    xp_progress = Gamification.xp_progress_in_level(profile.xp)
    user_skins = Skins.list_user_skins(scope)
    equipped_skin = Skins.get_equipped_skin(scope)
    all_skins = Skins.list_skins()
    enchantments = Enchantments.list_enchantments()
    equipped_enchantments = Enchantments.get_enchantment_summary(scope)
    skin_enchantments = if equipped_skin, do: Enchantments.list_skin_enchantments(equipped_skin.id), else: []

    {:ok,
     socket
     |> assign(:page_title, "Profil")
     |> assign(:profile, profile)
     |> assign(:xp_progress, xp_progress)
     |> assign(:user_skins, user_skins)
     |> assign(:equipped_skin, equipped_skin)
     |> assign(:all_skins, all_skins)
     |> assign(:enchantments, enchantments)
     |> assign(:equipped_enchantments, equipped_enchantments)
     |> assign(:skin_enchantments, skin_enchantments)
     |> assign(:current_page, :profile)
     |> assign(:tab, :overview)
     |> assign(:enchant_target, nil)}
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
        <a href="/" class="text-2xl font-black text-transparent bg-clip-text bg-gradient-to-r from-purple-500 to-violet-500 tracking-wider">
          SHDXW
        </a>
      </div>

      <.gamification_bar profile={@profile} xp_progress={@xp_progress} />
      <.app_nav current_page={@current_page} current_scope={@current_scope} />

      <Layouts.flash_group flash={@flash} />

      <div class="relative z-10 px-6 py-8 mx-auto max-w-6xl">
        <%!-- Header --%>
        <div class="mb-10">
          <h1 class="text-5xl font-black text-white tracking-wider mb-2">
            <span class="text-purple-500">Pro</span>fil
          </h1>
          <div class="w-32 h-1 bg-gradient-to-r from-purple-500 to-transparent rounded-full mb-4" />
        </div>

        <%!-- Profile Card --%>
        <div class="bg-gradient-to-br from-purple-950/40 to-black border border-purple-500/20 rounded-2xl p-8 mb-8">
          <div class="flex items-center gap-6">
            <%!-- Avatar with skin --%>
            <div class="relative">
              <div class={[
                "w-24 h-24 rounded-full flex items-center justify-center text-4xl border-2 shadow-lg",
                skin_border_class(@equipped_skin)
              ]}>
                {if @equipped_skin, do: @equipped_skin.skin.icon, else: "👤"}
              </div>
              <div :if={@equipped_skin} class={[
                "absolute -bottom-1 -right-1 px-2 py-0.5 rounded-full text-[10px] font-black uppercase tracking-wider",
                rarity_badge_class(@equipped_skin.skin.rarity)
              ]}>
                {@equipped_skin.skin.rarity}
              </div>
            </div>

            <div class="flex-1">
              <div class="text-2xl font-black text-white">{@current_scope.user.email}</div>
              <div class="text-purple-400 font-bold">{@profile.title} — Niveau {@profile.level}</div>
              <div :if={@equipped_skin} class="text-white/40 text-sm mt-1">
                Skin: {@equipped_skin.skin.name}
              </div>

              <%!-- Active boosts from skin + enchantments --%>
              <div class="flex flex-wrap gap-2 mt-3">
                <div :if={@equipped_skin && @equipped_skin.skin.xp_boost_percent > 0}
                  class="px-2 py-1 rounded-lg bg-purple-600/20 border border-purple-500/30 text-xs text-purple-300">
                  ✨ +{@equipped_skin.skin.xp_boost_percent}% XP (skin)
                </div>
                <div :if={@equipped_skin && @equipped_skin.skin.gold_boost_percent > 0}
                  class="px-2 py-1 rounded-lg bg-amber-600/20 border border-amber-500/30 text-xs text-amber-300">
                  💰 +{@equipped_skin.skin.gold_boost_percent}% Or (skin)
                </div>
                <div :for={ench <- @equipped_enchantments}
                  class="px-2 py-1 rounded-lg bg-cyan-600/20 border border-cyan-500/30 text-xs text-cyan-300">
                  {ench.icon} {ench.name} {ench.roman} (+{ench.effect}%)
                </div>
              </div>
            </div>

            <%!-- Stats rapides --%>
            <div class="hidden md:grid grid-cols-2 gap-3">
              <div class="text-center">
                <div class="text-xl font-black text-purple-400">{@profile.xp}</div>
                <div class="text-[10px] text-white/30 uppercase">XP Total</div>
              </div>
              <div class="text-center">
                <div class="text-xl font-black text-amber-400">{@profile.gold}</div>
                <div class="text-[10px] text-white/30 uppercase">Or</div>
              </div>
              <div class="text-center">
                <div class="text-xl font-black text-orange-400">{@profile.current_streak}</div>
                <div class="text-[10px] text-white/30 uppercase">Streak</div>
              </div>
              <div class="text-center">
                <div class="text-xl font-black text-emerald-400">{@profile.total_todos_completed}</div>
                <div class="text-[10px] text-white/30 uppercase">Taches</div>
              </div>
            </div>
          </div>
        </div>

        <%!-- Tabs --%>
        <div class="flex gap-2 mb-6">
          <button
            :for={{tab, label, icon} <- [
              {:overview, "Vue d'ensemble", "📊"},
              {:skins, "Skins", "🎨"},
              {:enchant, "Enchantements", "🔮"}
            ]}
            phx-click="switch_tab"
            phx-value-tab={tab}
            class={[
              "px-4 py-2 rounded-xl text-sm font-bold transition-all flex items-center gap-2",
              @tab == tab && "bg-purple-600/30 text-purple-300 border border-purple-500/30",
              @tab != tab && "text-white/40 hover:text-white/60 border border-transparent hover:bg-white/5"
            ]}
          >
            <span>{icon}</span>
            <span>{label}</span>
          </button>
        </div>

        <%!-- Tab Content --%>
        <div :if={@tab == :overview} class="space-y-6">
          <.render_overview profile={@profile} xp_progress={@xp_progress} />
        </div>

        <div :if={@tab == :skins}>
          <.render_skins
            all_skins={@all_skins}
            user_skins={@user_skins}
            equipped_skin={@equipped_skin}
            profile={@profile}
          />
        </div>

        <div :if={@tab == :enchant}>
          <.render_enchantments
            enchantments={@enchantments}
            equipped_skin={@equipped_skin}
            skin_enchantments={@skin_enchantments}
            profile={@profile}
            enchant_target={@enchant_target}
          />
        </div>
      </div>
    </div>
    """
  end

  # --- Overview Tab ---

  defp render_overview(assigns) do
    ~H"""
    <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
      <.stat_card icon="⚡" value={@profile.xp} label="XP Total" color="purple" />
      <.stat_card icon="💰" value={@profile.gold} label="Or" color="amber" />
      <.stat_card icon="🔥" value={@profile.current_streak} label="Streak actuel" color="orange" />
      <.stat_card icon="🏆" value={@profile.longest_streak} label="Meilleur streak" color="yellow" />
      <.stat_card icon="✅" value={@profile.total_todos_completed} label="Todos faites" color="emerald" />
      <.stat_card icon="🍅" value={@profile.total_pomodoros_completed} label="Pomodoros" color="red" />
      <.stat_card icon="🔄" value={@profile.total_habits_completed} label="Habitudes" color="blue" />
      <.stat_card icon="💎" value={@profile.total_gold_earned} label="Or total gagne" color="amber" />
    </div>

    <%!-- XP Progress --%>
    <div class="bg-gradient-to-br from-purple-950/40 to-black border border-purple-500/20 rounded-2xl p-6">
      <h3 class="font-black text-white mb-4">Progression vers le niveau {@profile.level + 1}</h3>
      <div class="w-full h-6 bg-white/5 rounded-full overflow-hidden">
        <div
          class="h-full bg-gradient-to-r from-purple-600 to-violet-500 rounded-full transition-all duration-1000 flex items-center justify-center"
          style={"width: #{@xp_progress.percent}%"}
        >
          <span :if={@xp_progress.percent > 15} class="text-xs font-bold text-white">
            {@xp_progress.percent}%
          </span>
        </div>
      </div>
      <div class="text-xs text-white/30 mt-2">
        {@xp_progress.current} / {@xp_progress.needed} XP
      </div>
    </div>
    """
  end

  defp stat_card(assigns) do
    ~H"""
    <div class="bg-gradient-to-br from-purple-950/40 to-black border border-purple-500/20 rounded-2xl p-5 text-center">
      <div class="text-2xl mb-1">{@icon}</div>
      <div class={"text-2xl font-black text-#{@color}-400"}>{@value}</div>
      <div class="text-[10px] text-white/40 uppercase tracking-wider mt-1">{@label}</div>
    </div>
    """
  end

  # --- Skins Tab ---

  defp render_skins(assigns) do
    ~H"""
    <div class="space-y-6">
      <%!-- Owned Skins --%>
      <div :if={@user_skins != []}>
        <h3 class="font-black text-white tracking-wider mb-4 text-lg">Mes Skins</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          <div
            :for={us <- @user_skins}
            class={[
              "bg-gradient-to-br from-purple-950/40 to-black border rounded-2xl p-5 transition-all",
              us.equipped && "border-purple-500/50 shadow-lg shadow-purple-600/20",
              !us.equipped && "border-purple-500/20 hover:border-purple-500/40"
            ]}
          >
            <div class="flex items-center gap-3 mb-3">
              <div class="text-3xl">{us.skin.icon}</div>
              <div>
                <div class="font-bold text-white">{us.skin.name}</div>
                <div class={["text-xs font-bold uppercase", rarity_text_class(us.skin.rarity)]}>
                  {us.skin.rarity}
                </div>
              </div>
            </div>
            <p class="text-xs text-white/40 mb-3">{us.skin.description}</p>
            <div class="flex gap-2 mb-3">
              <span :if={us.skin.xp_boost_percent > 0} class="text-xs text-purple-300 bg-purple-600/20 px-2 py-0.5 rounded">
                +{us.skin.xp_boost_percent}% XP
              </span>
              <span :if={us.skin.gold_boost_percent > 0} class="text-xs text-amber-300 bg-amber-600/20 px-2 py-0.5 rounded">
                +{us.skin.gold_boost_percent}% Or
              </span>
              <span class="text-xs text-cyan-300 bg-cyan-600/20 px-2 py-0.5 rounded">
                {us.skin.enchantment_slots} slots
              </span>
            </div>
            <button
              :if={!us.equipped}
              phx-click="equip_skin"
              phx-value-id={us.id}
              class="w-full py-2 rounded-xl bg-purple-600/30 text-purple-300 text-sm font-bold hover:bg-purple-600/50 transition-all border border-purple-500/30"
            >
              Equiper
            </button>
            <div :if={us.equipped} class="w-full py-2 rounded-xl text-center text-emerald-400 text-sm font-bold bg-emerald-600/10 border border-emerald-500/20">
              Equipee ✓
            </div>
          </div>
        </div>
      </div>

      <%!-- Shop --%>
      <h3 class="font-black text-white tracking-wider mb-4 text-lg">Boutique de Skins</h3>
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <div
          :for={skin <- @all_skins}
          :if={!skin_owned?(@user_skins, skin.id)}
          class={[
            "bg-gradient-to-br from-purple-950/40 to-black border rounded-2xl p-5 transition-all",
            can_buy?(@profile, skin) && "border-purple-500/20 hover:border-purple-500/40",
            !can_buy?(@profile, skin) && "border-white/5 opacity-60"
          ]}
        >
          <div class="flex items-center gap-3 mb-3">
            <div class="text-3xl">{skin.icon}</div>
            <div>
              <div class="font-bold text-white">{skin.name}</div>
              <div class={["text-xs font-bold uppercase", rarity_text_class(skin.rarity)]}>
                {skin.rarity}
              </div>
            </div>
          </div>
          <p class="text-xs text-white/40 mb-3">{skin.description}</p>
          <div class="flex gap-2 mb-3">
            <span :if={skin.xp_boost_percent > 0} class="text-xs text-purple-300 bg-purple-600/20 px-2 py-0.5 rounded">
              +{skin.xp_boost_percent}% XP
            </span>
            <span :if={skin.gold_boost_percent > 0} class="text-xs text-amber-300 bg-amber-600/20 px-2 py-0.5 rounded">
              +{skin.gold_boost_percent}% Or
            </span>
            <span class="text-xs text-cyan-300 bg-cyan-600/20 px-2 py-0.5 rounded">
              {skin.enchantment_slots} slots
            </span>
          </div>
          <div class="flex items-center justify-between mb-2">
            <span class="text-amber-400 font-bold text-sm">💰 {skin.price}</span>
            <span :if={skin.level_required > 1} class="text-white/30 text-xs">Niv. {skin.level_required}+</span>
          </div>
          <button
            :if={can_buy?(@profile, skin)}
            phx-click="buy_skin"
            phx-value-id={skin.id}
            class="w-full py-2 rounded-xl bg-amber-600/30 text-amber-300 text-sm font-bold hover:bg-amber-600/50 transition-all border border-amber-500/30"
          >
            Acheter
          </button>
          <div :if={!can_buy?(@profile, skin)} class="w-full py-2 rounded-xl text-center text-white/20 text-sm">
            {cond do
              @profile.level < skin.level_required -> "Niveau #{skin.level_required} requis"
              @profile.gold < skin.price -> "Or insuffisant"
              true -> "Indisponible"
            end}
          </div>
        </div>
      </div>
    </div>
    """
  end

  # --- Enchantments Tab ---

  defp render_enchantments(assigns) do
    ~H"""
    <div class="space-y-6">
      <div :if={@equipped_skin == nil} class="bg-gradient-to-br from-purple-950/40 to-black border border-purple-500/20 rounded-2xl p-12 text-center">
        <div class="text-4xl mb-4">🔮</div>
        <div class="text-white/40 text-lg">Equipez une skin pour pouvoir l'enchanter</div>
      </div>

      <div :if={@equipped_skin != nil}>
        <%!-- Current enchantments on equipped skin --%>
        <div class="bg-gradient-to-br from-purple-950/40 to-black border border-purple-500/20 rounded-2xl p-6 mb-6">
          <h3 class="font-black text-white tracking-wider mb-4 flex items-center gap-2">
            <span class="text-xl">🔮</span>
            <span>Enchantements sur <span class="text-purple-400">{@equipped_skin.skin.name}</span></span>
            <span class="text-white/30 text-sm font-normal ml-2">
              ({length(@skin_enchantments)}/{@equipped_skin.skin.enchantment_slots} slots)
            </span>
          </h3>

          <div :if={@skin_enchantments == []} class="text-white/30 text-sm py-4">
            Aucun enchantement applique. Choisissez un enchantement ci-dessous.
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-3">
            <div
              :for={se <- @skin_enchantments}
              class="flex items-center gap-3 p-3 rounded-xl bg-white/5 border border-cyan-500/20"
            >
              <div class="text-2xl">{se.enchantment.icon}</div>
              <div class="flex-1">
                <div class="text-white font-bold text-sm">
                  {se.enchantment.name} {to_roman(se.level)}
                </div>
                <div class="text-white/40 text-xs">{se.enchantment.description}</div>
                <div class="text-cyan-400 text-xs mt-1">
                  Effet: +{Shdxw.Enchantments.Enchantment.effect_at_level(se.enchantment, se.level)}%
                </div>
              </div>
              <button
                :if={se.level < se.enchantment.max_level}
                phx-click="enchant"
                phx-value-enchantment-id={se.enchantment.id}
                class="px-3 py-1 rounded-lg bg-cyan-600/20 text-cyan-300 text-xs font-bold hover:bg-cyan-600/40 transition-all border border-cyan-500/30"
              >
                ↑ Niv. {se.level + 1}
                <span class="text-amber-400 ml-1">
                  💰{Shdxw.Enchantments.Enchantment.cost_for_level(se.enchantment, se.level + 1)}
                </span>
              </button>
              <span :if={se.level >= se.enchantment.max_level} class="text-amber-400 text-xs font-bold">MAX</span>
            </div>
          </div>
        </div>

        <%!-- Available enchantments --%>
        <h3 class="font-black text-white tracking-wider mb-4 text-lg">Table d'Enchantement</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div
            :for={ench <- @enchantments}
            class={[
              "bg-gradient-to-br from-purple-950/40 to-black border rounded-2xl p-5 transition-all",
              can_enchant?(@profile, ench) && "border-cyan-500/20 hover:border-cyan-500/40",
              !can_enchant?(@profile, ench) && "border-white/5 opacity-50"
            ]}
          >
            <div class="flex items-center gap-3 mb-2">
              <div class="text-2xl">{ench.icon}</div>
              <div>
                <div class="font-bold text-white">{ench.name}</div>
                <div class={["text-xs font-bold uppercase", rarity_text_class(ench.rarity)]}>
                  {ench.rarity} — Max niveau {ench.max_level}
                </div>
              </div>
            </div>
            <p class="text-xs text-white/40 mb-3">{ench.description}</p>
            <div class="flex items-center justify-between">
              <span class="text-cyan-400 text-xs">
                +{ench.effect_per_level}% par niveau
              </span>
              <span class="text-amber-400 text-xs font-bold">
                💰 {Shdxw.Enchantments.Enchantment.cost_for_level(ench, get_current_level(@skin_enchantments, ench.id) + 1)}
              </span>
            </div>
            <button
              :if={can_enchant?(@profile, ench)}
              phx-click="enchant"
              phx-value-enchantment-id={ench.id}
              class="w-full mt-3 py-2 rounded-xl bg-cyan-600/20 text-cyan-300 text-sm font-bold hover:bg-cyan-600/40 transition-all border border-cyan-500/30"
            >
              🔮 Enchanter
            </button>
            <div :if={!can_enchant?(@profile, ench)} class="w-full mt-3 py-2 rounded-xl text-center text-white/20 text-xs">
              Niveau {ench.min_player_level} requis
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

  def handle_event("equip_skin", %{"id" => id}, socket) do
    scope = socket.assigns.current_scope

    case Skins.equip_skin(scope, String.to_integer(id)) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Skin equipee !")
         |> reload_data()}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Erreur lors de l'equipement")}
    end
  end

  def handle_event("buy_skin", %{"id" => id}, socket) do
    scope = socket.assigns.current_scope

    case Skins.purchase_skin(scope, String.to_integer(id)) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Skin achetee !")
         |> reload_data()}

      {:error, :insufficient_gold} ->
        {:noreply, put_flash(socket, :error, "Or insuffisant")}

      {:error, :level_required} ->
        {:noreply, put_flash(socket, :error, "Niveau insuffisant")}

      {:error, :already_owned} ->
        {:noreply, put_flash(socket, :error, "Skin deja possedee")}
    end
  end

  def handle_event("enchant", %{"enchantment-id" => ench_id}, socket) do
    scope = socket.assigns.current_scope
    equipped = socket.assigns.equipped_skin

    if equipped do
      case Enchantments.enchant_skin(scope, equipped.id, String.to_integer(ench_id)) do
        {:ok, _} ->
          {:noreply,
           socket
           |> put_flash(:info, "Enchantement applique !")
           |> reload_data()}

        {:error, :insufficient_gold} ->
          {:noreply, put_flash(socket, :error, "Or insuffisant")}

        {:error, :max_level_reached} ->
          {:noreply, put_flash(socket, :error, "Niveau max atteint")}

        {:error, :no_slots_available} ->
          {:noreply, put_flash(socket, :error, "Plus de slots disponibles")}

        {:error, :level_required} ->
          {:noreply, put_flash(socket, :error, "Niveau insuffisant")}

        {:error, _} ->
          {:noreply, put_flash(socket, :error, "Erreur")}
      end
    else
      {:noreply, put_flash(socket, :error, "Equipez d'abord une skin")}
    end
  end

  # --- PubSub ---

  @impl true
  def handle_info({event, _payload}, socket)
      when event in [:xp_gained, :level_up, :streak_updated, :gold_spent] do
    {:noreply, reload_data(socket)}
  end

  def handle_info(_, socket), do: {:noreply, socket}

  # --- Helpers ---

  defp reload_data(socket) do
    scope = socket.assigns.current_scope
    profile = Gamification.get_or_create_profile(scope)
    equipped_skin = Skins.get_equipped_skin(scope)

    socket
    |> assign(:profile, profile)
    |> assign(:xp_progress, Gamification.xp_progress_in_level(profile.xp))
    |> assign(:user_skins, Skins.list_user_skins(scope))
    |> assign(:equipped_skin, equipped_skin)
    |> assign(:all_skins, Skins.list_skins())
    |> assign(:equipped_enchantments, Enchantments.get_enchantment_summary(scope))
    |> assign(:skin_enchantments, if(equipped_skin, do: Enchantments.list_skin_enchantments(equipped_skin.id), else: []))
  end

  defp skin_owned?(user_skins, skin_id) do
    Enum.any?(user_skins, fn us -> us.skin_id == skin_id end)
  end

  defp can_buy?(profile, skin) do
    profile.gold >= skin.price and profile.level >= skin.level_required
  end

  defp can_enchant?(profile, enchantment) do
    profile.level >= enchantment.min_player_level
  end

  defp get_current_level(skin_enchantments, enchantment_id) do
    case Enum.find(skin_enchantments, fn se -> se.enchantment_id == enchantment_id end) do
      nil -> 0
      se -> se.level
    end
  end

  defp to_roman(1), do: "I"
  defp to_roman(2), do: "II"
  defp to_roman(3), do: "III"
  defp to_roman(4), do: "IV"
  defp to_roman(5), do: "V"
  defp to_roman(n), do: "#{n}"

  defp skin_border_class(nil), do: "border-white/20 bg-white/5"
  defp skin_border_class(us) do
    case us.skin.rarity do
      :common -> "border-gray-400/50 bg-gray-900/50"
      :rare -> "border-blue-400/50 bg-blue-900/30"
      :epic -> "border-purple-400/50 bg-purple-900/30"
      :legendary -> "border-amber-400/50 bg-amber-900/30"
      :mythic -> "border-red-400/50 bg-red-900/30 animate-pulse"
    end
  end

  defp rarity_badge_class(rarity) do
    case rarity do
      :common -> "bg-gray-600/80 text-gray-200"
      :rare -> "bg-blue-600/80 text-blue-200"
      :epic -> "bg-purple-600/80 text-purple-200"
      :legendary -> "bg-amber-600/80 text-amber-200"
      :mythic -> "bg-red-600/80 text-red-200"
    end
  end

  defp rarity_text_class(rarity) do
    case rarity do
      :common -> "text-gray-400"
      :rare -> "text-blue-400"
      :epic -> "text-purple-400"
      :legendary -> "text-amber-400"
      :mythic -> "text-red-400"
    end
  end
end
