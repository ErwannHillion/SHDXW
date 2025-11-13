defmodule ShdxwWeb.Homepage do
  use ShdxwWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "SHDXW - Shadow Developer")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-black">
      <!-- Hero Section -->
      <div class="hero min-h-screen relative overflow-hidden">
        <!-- Animated background -->
        <div class="absolute inset-0 bg-gradient-to-br from-black via-purple-950/30 to-black"></div>
        <div class="absolute inset-0">
          <div class="absolute top-1/4 left-1/4 w-96 h-96 bg-purple-600/10 rounded-full blur-3xl animate-pulse">
          </div>
          <div class="absolute bottom-1/4 right-1/4 w-96 h-96 bg-violet-600/10 rounded-full blur-3xl animate-pulse delay-75">
          </div>
        </div>

        <div class="hero-content text-center z-10 relative">
          <div class="max-w-4xl">
            <div class="mb-8 flex justify-center">
              <div class="relative">
                <h1 class="text-9xl font-black text-white drop-shadow-2xl tracking-wider">
                  SHDXW
                </h1>
                <div class="absolute inset-0 blur-3xl opacity-60 bg-gradient-to-r from-purple-500 via-violet-500 to-purple-600">
                </div>
                <div class="absolute -bottom-4 left-0 right-0 h-1 bg-gradient-to-r from-transparent via-purple-500 to-transparent">
                </div>
              </div>
            </div>
            <p class="text-2xl md:text-3xl mb-8 text-white/90 font-light tracking-widest">
              DÉVELOPPEUR FULL-STACK
            </p>
            <p class="text-lg mb-12 text-white/60 max-w-2xl mx-auto leading-relaxed">
              Dans l'obscurité naissent les meilleures créations.
              Je façonne des expériences digitales exceptionnelles avec précision et innovation.
            </p>
            <div class="flex gap-4 justify-center flex-wrap">
              <a
                href="#projets"
                class="btn bg-purple-600 hover:bg-purple-700 border-none text-white btn-lg shadow-lg shadow-purple-600/50 hover:shadow-purple-600/80 transition-all"
              >
                <span class="flex items-center gap-2">
                  EXPLORER
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    class="h-5 w-5"
                    viewBox="0 0 20 20"
                    fill="currentColor"
                  >
                    <path
                      fill-rule="evenodd"
                      d="M10.293 3.293a1 1 0 011.414 0l6 6a1 1 0 010 1.414l-6 6a1 1 0 01-1.414-1.414L14.586 11H3a1 1 0 110-2h11.586l-4.293-4.293a1 1 0 010-1.414z"
                      clip-rule="evenodd"
                    />
                  </svg>
                </span>
              </a>
              <a
                href="#contact"
                class="btn bg-transparent hover:bg-white/10 border-2 border-white/30 hover:border-purple-500 text-white btn-lg transition-all"
              >
                CONTACT
              </a>
            </div>
          </div>
        </div>
      </div>
      
    <!-- Section en construction-->
      <div id="en construction" class="py-32 px-4 bg-black relative overflow-hidden">
        <div class="absolute inset-0 bg-gradient-to-t from-purple-950/20 to-transparent"></div>

        <div class="max-w-4xl mx-auto text-center relative">
          <h2 class="text-6xl font-black mb-8 text-white tracking-wider">
            EN CONSTRUCTION
          </h2>
          <div class="w-32 h-1 bg-gradient-to-r from-transparent via-purple-500 to-transparent mx-auto rounded-full mb-8">
          </div>
          <p class="text-xl text-white/60 mb-16 tracking-wide">
            Cette site est en construction. Revenez bientôt pour découvrir mes projets passionnants !
          </p>
        </div>
      </div>
      <!-- Contact Section -->
      <div id="contact" class="py-32 px-4 bg-black relative overflow-hidden">
        <div class="absolute inset-0 bg-gradient-to-t from-purple-950/20 to-transparent"></div>

        <div class="max-w-4xl mx-auto text-center relative">
          <h2 class="text-6xl font-black mb-8 text-white tracking-wider">
            COLLABORATION
          </h2>
          <div class="w-32 h-1 bg-gradient-to-r from-transparent via-purple-500 to-transparent mx-auto rounded-full mb-8">
          </div>
          <p class="text-xl text-white/60 mb-16 tracking-wide">
            ME SUIVRE ET ME CONTACTER
          </p>

          <div class="flex gap-6 justify-center flex-wrap">
            <a
              href="mailto:contact@shdxw.dev"
              class="group relative px-8 py-4 bg-gradient-to-r from-purple-600 to-violet-600 rounded-lg overflow-hidden transition-all duration-300 hover:shadow-2xl hover:shadow-purple-600/50"
            >
              <div class="absolute inset-0 bg-white/20 transform scale-x-0 group-hover:scale-x-100 transition-transform origin-left duration-300">
              </div>
              <span class="relative flex items-center gap-3 text-white font-semibold text-lg">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class="h-6 w-6"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"
                  />
                </svg>
                EMAIL
              </span>
            </a>

            <a
              href="https://github.com/shdxw"
              target="_blank"
              class="group px-8 py-4 bg-white/5 border-2 border-white/20 hover:border-purple-500 rounded-lg transition-all duration-300"
            >
              <span class="flex items-center gap-3 text-white font-semibold text-lg">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class="h-6 w-6"
                  fill="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z" />
                </svg>
                GITHUB
              </span>
            </a>

            <a
              href="https://linkedin.com/in/shdxw"
              target="_blank"
              class="group px-8 py-4 bg-white/5 border-2 border-white/20 hover:border-purple-500 rounded-lg transition-all duration-300"
            >
              <span class="flex items-center gap-3 text-white font-semibold text-lg">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class="h-6 w-6"
                  fill="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path d="M19 0h-14c-2.761 0-5 2.239-5 5v14c0 2.761 2.239 5 5 5h14c2.762 0 5-2.239 5-5v-14c0-2.761-2.238-5-5-5zm-11 19h-3v-11h3v11zm-1.5-12.268c-.966 0-1.75-.79-1.75-1.764s.784-1.764 1.75-1.764 1.75.79 1.75 1.764-.783 1.764-1.75 1.764zm13.5 12.268h-3v-5.604c0-3.368-4-3.113-4 0v5.604h-3v-11h3v1.765c1.396-2.586 7-2.777 7 2.476v6.759z" />
                </svg>
                LINKEDIN
              </span>
            </a>
          </div>
        </div>
      </div>
      
    <!-- Footer -->
      <footer class="py-12 px-4 bg-black border-t border-white/10">
        <div class="max-w-7xl mx-auto text-center">
          <div class="mb-4">
            <p class="text-4xl font-black text-transparent bg-clip-text bg-gradient-to-r from-purple-500 to-violet-500 tracking-wider">
              SHDXW
            </p>
          </div>
          <p class="text-white/40 tracking-widest text-sm">
            © {DateTime.utc_now().year} - ALL RIGHTS RESERVED
          </p>
        </div>
      </footer>
    </div>
    """
  end
end
