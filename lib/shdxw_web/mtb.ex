defmodule ShdxwWeb.Mtb do
  use ShdxwWeb, :live_view

  alias ShdxwWeb.Helpers.Cipher

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "SHDXW - MTB Cipher")
     |> assign(:input_text, "")
     |> assign(:encoded_text, "")
     |> assign(:decode_input, "")
     |> assign(:decoded_text, "")
     |> assign(:decode_error, nil)
     |> assign(:copied, false)}
  end

  @impl true
  def handle_event("encode", %{"text" => text}, socket) do
    encoded = Cipher.encode(text)

    {:noreply,
     socket
     |> assign(:input_text, text)
     |> assign(:encoded_text, encoded)
     |> assign(:copied, false)}
  end

  def handle_event("decode", %{"text" => text}, socket) do
    case Cipher.decode(text) do
      {:ok, decoded} ->
        {:noreply,
         socket
         |> assign(:decode_input, text)
         |> assign(:decoded_text, decoded)
         |> assign(:decode_error, nil)}

      {:error, reason} ->
        {:noreply,
         socket
         |> assign(:decode_input, text)
         |> assign(:decoded_text, "")
         |> assign(:decode_error, reason)}
    end
  end

  def handle_event("copy_encoded", _, socket) do
    {:noreply,
     socket
     |> assign(:copied, true)
     |> push_event("clipboard", %{text: socket.assigns.encoded_text})}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-black text-white">
      <!-- Header -->
      <div class="border-b border-purple-500/20">
        <div class="max-w-4xl mx-auto px-6 py-4 flex items-center justify-between">
          <a href="/" class="flex items-center gap-3 hover:opacity-80 transition-opacity">
            <div class="w-8 h-8 bg-gradient-to-br from-purple-500 to-violet-600 rounded-lg flex items-center justify-center">
              <span class="text-white text-sm font-black">S</span>
            </div>
            <span class="text-white/60 text-sm">SHDXW</span>
          </a>
          <span class="text-white/30 text-xs font-mono">MTB CIPHER</span>
        </div>
      </div>

      <div class="max-w-4xl mx-auto px-6 py-16">
        <!-- Title -->
        <div class="text-center mb-16">
          <h1 class="text-5xl font-black mb-3 tracking-wider">
            MTB <span class="text-transparent bg-clip-text bg-gradient-to-r from-purple-400 to-violet-400">CIPHER</span>
          </h1>
          <p class="text-white/50">Encodeur runique SHDXW</p>
        </div>

        <div class="grid gap-12">
          <!-- Encode Section -->
          <div class="bg-gray-900/50 rounded-2xl border border-purple-500/20 overflow-hidden">
            <div class="bg-purple-600/10 border-b border-purple-500/20 px-6 py-3 flex items-center gap-2">
              <div class="w-2 h-2 rounded-full bg-purple-500"></div>
              <span class="text-purple-400 text-sm font-semibold uppercase tracking-wider">Encoder</span>
            </div>

            <div class="p-6">
              <form phx-change="encode" class="space-y-4">
                <div>
                  <label class="text-white/60 text-xs uppercase tracking-wider mb-2 block">Texte en clair</label>
                  <textarea
                    name="text"
                    value={@input_text}
                    placeholder="Écrivez votre message ici..."
                    class="w-full h-28 bg-black/50 text-white border border-white/10 rounded-xl px-4 py-3 font-mono text-sm focus:outline-none focus:border-purple-500/50 resize-none placeholder:text-white/20"
                    phx-debounce="150"
                  ><%= @input_text %></textarea>
                </div>
              </form>

              <%= if @encoded_text != "" do %>
                <div class="mt-6">
                  <div class="flex items-center justify-between mb-2">
                    <label class="text-white/60 text-xs uppercase tracking-wider">Texte runique</label>
                    <button
                      phx-click="copy_encoded"
                      id="copy-btn"
                      phx-hook="Clipboard"
                      class="text-xs px-3 py-1 rounded-lg bg-purple-600/20 hover:bg-purple-600/40 text-purple-400 transition-all"
                    >
                      <%= if @copied, do: "Copie !", else: "Copier" %>
                    </button>
                  </div>
                  <div class="bg-black/50 border border-purple-500/20 rounded-xl p-4 font-mono text-lg text-purple-300 break-all leading-relaxed select-all">
                    <%= @encoded_text %>
                  </div>
                </div>
              <% end %>
            </div>
          </div>

          <!-- Decode Section -->
          <%!-- <div class="bg-gray-900/50 rounded-2xl border border-purple-500/20 overflow-hidden">
            <div class="bg-violet-600/10 border-b border-purple-500/20 px-6 py-3 flex items-center gap-2">
              <div class="w-2 h-2 rounded-full bg-violet-500"></div>
              <span class="text-violet-400 text-sm font-semibold uppercase tracking-wider">Decoder</span>
            </div>

            <div class="p-6">
              <form phx-change="decode" class="space-y-4">
                <div>
                  <label class="text-white/60 text-xs uppercase tracking-wider mb-2 block">Texte runique</label>
                  <textarea
                    name="text"
                    value={@decode_input}
                    placeholder="Collez du texte runique ici..."
                    class="w-full h-28 bg-black/50 text-purple-300 border border-white/10 rounded-xl px-4 py-3 font-mono text-sm focus:outline-none focus:border-violet-500/50 resize-none placeholder:text-white/20"
                    phx-debounce="150"
                  ><%= @decode_input %></textarea>
                </div>
              </form>

              <%= if @decoded_text != "" do %>
                <div class="mt-6">
                  <label class="text-white/60 text-xs uppercase tracking-wider mb-2 block">Texte decodé</label>
                  <div class="bg-black/50 border border-green-500/20 rounded-xl p-4 text-green-400 font-mono text-sm">
                    <%= @decoded_text %>
                  </div>
                </div>
              <% end %>

              <%= if @decode_error do %>
                <div class="mt-4">
                  <div class="bg-red-950/30 border border-red-500/30 rounded-xl p-4 text-red-400 text-sm">
                    <%= @decode_error %>
                  </div>
                </div>
              <% end %>
            </div>
          </div> --%>

          <!-- Info -->
          <div class="bg-gray-900/50 rounded-2xl border border-white/10 p-6 text-center">
            <p class="text-white/30 text-sm">
              Chiffrement runique SHDXW &mdash; La clé est protégée par variables d'environnement.
            </p>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
