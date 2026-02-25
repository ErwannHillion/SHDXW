defmodule ShdxwWeb.UserLive.Login do
  use ShdxwWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    email =
      Phoenix.Flash.get(socket.assigns.flash, :email) ||
        get_in(socket.assigns, [:current_scope, Access.key(:user), Access.key(:email)])

    form = to_form(%{"email" => email}, as: "user")

    {:ok,
     socket
     |> assign(:page_title, "Connexion")
     |> assign(form: form, trigger_submit: false)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-black flex items-center justify-center relative overflow-hidden">
      <%!-- Background effects --%>
      <div class="absolute inset-0 bg-gradient-to-br from-black via-purple-950/30 to-black" />
      <div class="absolute inset-0">
        <div class="absolute top-1/4 left-1/4 w-96 h-96 bg-purple-600/10 rounded-full blur-3xl animate-pulse" />
        <div class="absolute bottom-1/4 right-1/4 w-96 h-96 bg-violet-600/10 rounded-full blur-3xl animate-pulse delay-75" />
      </div>

      <%!-- Flash --%>
      <div class="fixed top-4 right-4 z-50">
        <Layouts.flash_group flash={@flash} />
      </div>

      <%!-- Login card --%>
      <div class="relative z-10 w-full max-w-md mx-4">
        <%!-- Logo --%>
        <div class="text-center mb-10">
          <a href="/" class="inline-block">
            <div class="relative">
              <h1 class="text-7xl font-black text-white drop-shadow-2xl tracking-wider">
                SHDXW
              </h1>
              <div class="absolute inset-0 blur-3xl opacity-40 bg-gradient-to-r from-purple-500 via-violet-500 to-purple-600" />
              <div class="absolute -bottom-3 left-0 right-0 h-0.5 bg-gradient-to-r from-transparent via-purple-500 to-transparent" />
            </div>
          </a>
        </div>

        <%!-- Card --%>
        <div class="bg-gradient-to-br from-purple-950/40 to-black border border-purple-500/20 rounded-2xl p-8 shadow-2xl shadow-purple-600/5">
          <h2 class="text-2xl font-black text-white tracking-wider mb-1 text-center">
            <span class="text-purple-500">Connexion</span>
          </h2>
          <p class="text-sm text-white/40 text-center mb-8 tracking-wide">
            Accédez à votre espace
          </p>

          <.form
            for={@form}
            id="login_form"
            action={~p"/users/log-in"}
            phx-submit="submit"
            phx-trigger-action={@trigger_submit}
          >
            <%!-- Email --%>
            <div class="mb-5">
              <label class="text-xs text-white/40 tracking-wider uppercase mb-2 block font-semibold">
                Email
              </label>
              <div class="relative">
                <div class="absolute inset-y-0 left-0 flex items-center pl-4 pointer-events-none">
                  <.icon name="hero-envelope" class="size-5 text-white/20" />
                </div>
                <input
                  type="email"
                  name={@form[:email].name}
                  value={@form[:email].value}
                  readonly={!!@current_scope}
                  placeholder="votre@email.fr"
                  required
                  autocomplete="username"
                  phx-mounted={JS.focus()}
                  class="w-full bg-white/5 border border-white/10 focus:border-purple-500/50 rounded-xl pl-12 pr-4 py-3 text-white placeholder-white/20 outline-none transition-all focus:shadow-lg focus:shadow-purple-600/10"
                />
              </div>
            </div>

            <%!-- Password --%>
            <div class="mb-6">
              <label class="text-xs text-white/40 tracking-wider uppercase mb-2 block font-semibold">
                Mot de passe
              </label>
              <div class="relative">
                <div class="absolute inset-y-0 left-0 flex items-center pl-4 pointer-events-none">
                  <.icon name="hero-lock-closed" class="size-5 text-white/20" />
                </div>
                <input
                  type="password"
                  name={@form[:password].name}
                  placeholder="••••••••••••"
                  autocomplete="current-password"
                  class="w-full bg-white/5 border border-white/10 focus:border-purple-500/50 rounded-xl pl-12 pr-4 py-3 text-white placeholder-white/20 outline-none transition-all focus:shadow-lg focus:shadow-purple-600/10"
                />
              </div>
            </div>

            <%!-- Remember me --%>
            <div class="flex items-center justify-between mb-8">
              <label class="flex items-center gap-2 cursor-pointer group">
                <input
                  type="checkbox"
                  name={@form[:remember_me].name}
                  value="true"
                  class="checkbox checkbox-sm border-white/20 checked:border-purple-500 [--chkbg:theme(colors.purple.600)] [--chkfg:white]"
                />
                <span class="text-sm text-white/40 group-hover:text-white/60 transition-colors">
                  Rester connecté
                </span>
              </label>
            </div>

            <%!-- Submit --%>
            <button
              type="submit"
              class="w-full py-3.5 bg-gradient-to-r from-purple-600 to-violet-600 hover:from-purple-700 hover:to-violet-700 text-white rounded-xl font-bold tracking-wider shadow-lg shadow-purple-600/30 hover:shadow-purple-600/50 transition-all duration-300 flex items-center justify-center gap-2"
            >
              SE CONNECTER
              <.icon name="hero-arrow-right" class="size-5" />
            </button>
          </.form>
        </div>

        <%!-- Footer --%>
        <div class="mt-8 text-center">
          <a href="/" class="text-sm text-white/30 hover:text-purple-400 transition-colors tracking-wide">
            &larr; Retour au site
          </a>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("submit", _params, socket) do
    {:noreply, assign(socket, :trigger_submit, true)}
  end
end
