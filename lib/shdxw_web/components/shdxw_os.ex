defmodule ShdxwWeb.Components.ShdxwOS do
  use ShdxwWeb, :live_component

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> assign(:windows, %{})
     |> assign(:active_window, nil)
     |> assign(:z_index_counter, 1)
     |> assign(:notepad_content, "Bienvenue sur SHDXW OS!\n\nCeci est un notepad. Vous pouvez écrire ce que vous voulez ici.\n\n- Essayez le Snake!\n- Jouez au Démineur!\n- Explorez les applications...")
     |> assign(:snake_game, init_snake_game())
     |> assign(:minesweeper_game, init_minesweeper_game())
     |> assign(:calculator_display, "0")
     |> assign(:calculator_memory, nil)
     |> assign(:calculator_operation, nil)
     |> assign(:calculator_new_number, true)}
  end

  defp init_snake_game do
    %{
      snake: [{10, 10}, {10, 11}, {10, 12}],
      direction: :up,
      food: {5, 5},
      score: 0,
      game_over: false,
      running: false,
      grid_size: 20
    }
  end

  defp init_minesweeper_game do
    size = 9
    mines = 10
    board = generate_minesweeper_board(size, mines)

    %{
      board: board,
      revealed: MapSet.new(),
      flagged: MapSet.new(),
      game_over: false,
      won: false,
      size: size,
      mines: mines
    }
  end

  defp generate_minesweeper_board(size, mine_count) do
    # Generate random mine positions
    all_positions = for x <- 0..(size-1), y <- 0..(size-1), do: {x, y}
    mine_positions = Enum.take_random(all_positions, mine_count) |> MapSet.new()

    # Create board with mine counts
    for x <- 0..(size-1), y <- 0..(size-1), into: %{} do
      is_mine = MapSet.member?(mine_positions, {x, y})
      adjacent_mines = if is_mine do
        -1
      else
        count_adjacent_mines({x, y}, mine_positions, size)
      end
      {{x, y}, %{mine: is_mine, adjacent: adjacent_mines}}
    end
  end

  defp count_adjacent_mines({x, y}, mine_positions, size) do
    for dx <- -1..1, dy <- -1..1, {dx, dy} != {0, 0} do
      {x + dx, y + dy}
    end
    |> Enum.filter(fn {nx, ny} ->
      nx >= 0 and nx < size and ny >= 0 and ny < size
    end)
    |> Enum.count(fn pos -> MapSet.member?(mine_positions, pos) end)
  end

  @impl true
  def update(assigns, socket) do
    {:ok, assign(socket, :id, assigns.id)}
  end

  @impl true
  def handle_event("open_app", %{"app" => app}, socket) do
    window_id = "#{app}_#{System.unique_integer([:positive])}"

    window = %{
      id: window_id,
      app: app,
      title: get_app_title(app),
      x: 50 + :rand.uniform(100),
      y: 50 + :rand.uniform(50),
      width: get_app_width(app),
      height: get_app_height(app),
      minimized: false,
      z_index: socket.assigns.z_index_counter
    }

    windows = Map.put(socket.assigns.windows, window_id, window)

    {:noreply,
     socket
     |> assign(:windows, windows)
     |> assign(:active_window, window_id)
     |> assign(:z_index_counter, socket.assigns.z_index_counter + 1)}
  end

  def handle_event("close_window", %{"window-id" => window_id}, socket) do
    windows = Map.delete(socket.assigns.windows, window_id)
    active = if socket.assigns.active_window == window_id, do: nil, else: socket.assigns.active_window

    {:noreply,
     socket
     |> assign(:windows, windows)
     |> assign(:active_window, active)}
  end

  def handle_event("minimize_window", %{"window-id" => window_id}, socket) do
    windows = update_in(socket.assigns.windows, [window_id, :minimized], fn _ -> true end)
    {:noreply, assign(socket, :windows, windows)}
  end

  def handle_event("restore_window", %{"window-id" => window_id}, socket) do
    windows = update_in(socket.assigns.windows, [window_id, :minimized], fn _ -> false end)

    {:noreply,
     socket
     |> assign(:windows, windows)
     |> assign(:active_window, window_id)
     |> assign(:z_index_counter, socket.assigns.z_index_counter + 1)
     |> update_window_z_index(window_id)}
  end

  def handle_event("focus_window", %{"window-id" => window_id}, socket) do
    {:noreply,
     socket
     |> assign(:active_window, window_id)
     |> assign(:z_index_counter, socket.assigns.z_index_counter + 1)
     |> update_window_z_index(window_id)}
  end

  # Notepad events
  def handle_event("notepad_change", %{"content" => content}, socket) do
    {:noreply, assign(socket, :notepad_content, content)}
  end

  # Snake events
  def handle_event("snake_start", _, socket) do
    snake_game = if socket.assigns.snake_game.game_over do
      init_snake_game() |> Map.put(:running, true)
    else
      socket.assigns.snake_game |> Map.put(:running, true)
    end

    {:noreply,
     socket
     |> assign(:snake_game, snake_game)
     |> push_event("snake_started", %{})}
  end

  def handle_event("snake_tick", _, socket) do
    snake_game = socket.assigns.snake_game

    if snake_game.running and not snake_game.game_over do
      {:noreply, assign(socket, :snake_game, move_snake(snake_game))}
    else
      {:noreply, socket}
    end
  end

  defp move_snake(game) do
    [head | _] = game.snake
    {hx, hy} = head

    new_head = case game.direction do
      :up -> {hx, hy - 1}
      :down -> {hx, hy + 1}
      :left -> {hx - 1, hy}
      :right -> {hx + 1, hy}
    end

    {nx, ny} = new_head
    grid = game.grid_size

    cond do
      # Wall collision
      nx < 0 or nx >= grid or ny < 0 or ny >= grid ->
        %{game | game_over: true, running: false}

      # Self collision
      Enum.member?(game.snake, new_head) ->
        %{game | game_over: true, running: false}

      # Food eaten
      new_head == game.food ->
        new_snake = [new_head | game.snake]
        new_food = generate_food(new_snake, grid)
        %{game | snake: new_snake, food: new_food, score: game.score + 10}

      # Normal move
      true ->
        new_snake = [new_head | Enum.drop(game.snake, -1)]
        %{game | snake: new_snake}
    end
  end

  defp generate_food(snake, grid) do
    food = {:rand.uniform(grid) - 1, :rand.uniform(grid) - 1}
    if Enum.member?(snake, food), do: generate_food(snake, grid), else: food
  end

  def handle_event("snake_reset", _, socket) do
    {:noreply, assign(socket, :snake_game, init_snake_game())}
  end

  def handle_event("snake_direction", %{"direction" => direction}, socket) do
    snake_game = socket.assigns.snake_game
    new_direction = String.to_atom(direction)

    # Prevent 180 degree turns
    valid_change = case {snake_game.direction, new_direction} do
      {:up, :down} -> false
      {:down, :up} -> false
      {:left, :right} -> false
      {:right, :left} -> false
      _ -> true
    end

    if valid_change do
      {:noreply, assign(socket, :snake_game, %{snake_game | direction: new_direction})}
    else
      {:noreply, socket}
    end
  end

  # Minesweeper events
  def handle_event("minesweeper_reveal", %{"x" => x, "y" => y}, socket) do
    x = String.to_integer(x)
    y = String.to_integer(y)
    game = socket.assigns.minesweeper_game

    cond do
      game.game_over or game.won ->
        {:noreply, socket}
      MapSet.member?(game.flagged, {x, y}) ->
        {:noreply, socket}
      true ->
        game = reveal_cell(game, {x, y})
        {:noreply, assign(socket, :minesweeper_game, game)}
    end
  end

  def handle_event("minesweeper_flag", %{"x" => x, "y" => y}, socket) do
    x = String.to_integer(x)
    y = String.to_integer(y)
    game = socket.assigns.minesweeper_game

    cond do
      game.game_over or game.won ->
        {:noreply, socket}
      MapSet.member?(game.revealed, {x, y}) ->
        {:noreply, socket}
      MapSet.member?(game.flagged, {x, y}) ->
        {:noreply, assign(socket, :minesweeper_game, %{game | flagged: MapSet.delete(game.flagged, {x, y})})}
      true ->
        {:noreply, assign(socket, :minesweeper_game, %{game | flagged: MapSet.put(game.flagged, {x, y})})}
    end
  end

  def handle_event("minesweeper_reset", _, socket) do
    {:noreply, assign(socket, :minesweeper_game, init_minesweeper_game())}
  end

  # Calculator events
  def handle_event("calc_digit", %{"digit" => digit}, socket) do
    display = if socket.assigns.calculator_new_number do
      digit
    else
      socket.assigns.calculator_display <> digit
    end

    {:noreply,
     socket
     |> assign(:calculator_display, display)
     |> assign(:calculator_new_number, false)}
  end

  def handle_event("calc_operation", %{"op" => op}, socket) do
    current = parse_number(socket.assigns.calculator_display)

    result = if socket.assigns.calculator_memory && socket.assigns.calculator_operation do
      calculate(socket.assigns.calculator_memory, current, socket.assigns.calculator_operation)
    else
      current
    end

    {:noreply,
     socket
     |> assign(:calculator_display, format_number(result))
     |> assign(:calculator_memory, result)
     |> assign(:calculator_operation, op)
     |> assign(:calculator_new_number, true)}
  end

  def handle_event("calc_equals", _, socket) do
    if socket.assigns.calculator_memory && socket.assigns.calculator_operation do
      current = parse_number(socket.assigns.calculator_display)
      result = calculate(socket.assigns.calculator_memory, current, socket.assigns.calculator_operation)

      {:noreply,
       socket
       |> assign(:calculator_display, format_number(result))
       |> assign(:calculator_memory, nil)
       |> assign(:calculator_operation, nil)
       |> assign(:calculator_new_number, true)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("calc_clear", _, socket) do
    {:noreply,
     socket
     |> assign(:calculator_display, "0")
     |> assign(:calculator_memory, nil)
     |> assign(:calculator_operation, nil)
     |> assign(:calculator_new_number, true)}
  end

  def handle_event("calc_decimal", _, socket) do
    display = socket.assigns.calculator_display
    display = if socket.assigns.calculator_new_number do
      "0."
    else
      if String.contains?(display, "."), do: display, else: display <> "."
    end

    {:noreply,
     socket
     |> assign(:calculator_display, display)
     |> assign(:calculator_new_number, false)}
  end

  defp reveal_cell(game, {x, y}) do
    cell = Map.get(game.board, {x, y})

    cond do
      cell.mine ->
        %{game | game_over: true, revealed: MapSet.put(game.revealed, {x, y})}

      cell.adjacent == 0 ->
        revealed = flood_reveal(game.board, game.revealed, {x, y}, game.size)
        game = %{game | revealed: revealed}
        check_win(game)

      true ->
        game = %{game | revealed: MapSet.put(game.revealed, {x, y})}
        check_win(game)
    end
  end

  defp flood_reveal(board, revealed, {x, y}, size) do
    if x < 0 or x >= size or y < 0 or y >= size or MapSet.member?(revealed, {x, y}) do
      revealed
    else
      cell = Map.get(board, {x, y})
      revealed = MapSet.put(revealed, {x, y})

      if cell.adjacent == 0 do
        Enum.reduce(-1..1, revealed, fn dx, acc ->
          Enum.reduce(-1..1, acc, fn dy, acc2 ->
            if {dx, dy} != {0, 0} do
              flood_reveal(board, acc2, {x + dx, y + dy}, size)
            else
              acc2
            end
          end)
        end)
      else
        revealed
      end
    end
  end

  defp check_win(game) do
    non_mine_cells = Enum.count(game.board, fn {_, cell} -> not cell.mine end)
    revealed_count = MapSet.size(game.revealed)

    if revealed_count == non_mine_cells do
      %{game | won: true}
    else
      game
    end
  end

  defp calculate(a, b, op) do
    case op do
      "+" -> a + b
      "-" -> a - b
      "*" -> a * b
      "/" -> if b == 0, do: 0, else: a / b
      _ -> b
    end
  end

  defp parse_number(str) do
    case Float.parse(str) do
      {num, _} -> num
      :error -> 0
    end
  end

  defp format_number(num) when is_float(num) do
    if num == trunc(num), do: "#{trunc(num)}", else: "#{num}"
  end
  defp format_number(num), do: "#{num}"

  defp update_window_z_index(socket, window_id) do
    windows = update_in(socket.assigns.windows, [window_id, :z_index], fn _ ->
      socket.assigns.z_index_counter
    end)
    assign(socket, :windows, windows)
  end

  defp get_app_title(app) do
    case app do
      "notepad" -> "Notepad"
      "snake" -> "Snake"
      "minesweeper" -> "Démineur"
      "calculator" -> "Calculatrice"
      "terminal" -> "Terminal"
      _ -> "Application"
    end
  end

  defp get_app_width(app) do
    case app do
      "notepad" -> 500
      "snake" -> 440
      "minesweeper" -> 320
      "calculator" -> 280
      "terminal" -> 600
      _ -> 400
    end
  end

  defp get_app_height(app) do
    case app do
      "notepad" -> 400
      "snake" -> 520
      "minesweeper" -> 400
      "calculator" -> 420
      "terminal" -> 400
      _ -> 300
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id} class="os-container relative w-full h-[700px] bg-gradient-to-br from-gray-900 via-purple-950/50 to-gray-900 rounded-2xl border border-purple-500/30 overflow-hidden">
      <!-- Desktop -->
      <div class="desktop absolute inset-0 p-6 pb-16" phx-hook="ShdxwOS" id={"#{@id}-desktop"}>
        <!-- Desktop Icons -->
        <div class="grid grid-cols-6 gap-4">
          <.desktop_icon icon="notepad" label="Notepad" target={@myself} />
          <.desktop_icon icon="snake" label="Snake" target={@myself} />
          <.desktop_icon icon="minesweeper" label="Démineur" target={@myself} />
          <.desktop_icon icon="calculator" label="Calculatrice" target={@myself} />
        </div>

        <!-- Windows -->
        <%= for {window_id, window} <- @windows do %>
          <.window
            window={window}
            myself={@myself}
            active={@active_window == window_id}
            notepad_content={@notepad_content}
            snake_game={@snake_game}
            minesweeper_game={@minesweeper_game}
            calculator_display={@calculator_display}
          />
        <% end %>
      </div>

      <!-- Taskbar -->
      <div class="taskbar absolute bottom-0 left-0 right-0 h-14 bg-black/80 backdrop-blur-xl border-t border-purple-500/30 flex items-center px-4 gap-2">
        <!-- Start Button -->
        <div class="start-btn flex items-center gap-2 px-4 py-2 bg-purple-600/30 hover:bg-purple-600/50 rounded-lg cursor-pointer transition-all">
          <div class="w-6 h-6 bg-gradient-to-br from-purple-500 to-violet-600 rounded-md"></div>
          <span class="text-white font-semibold text-sm">SHDXW</span>
        </div>

        <div class="h-8 w-px bg-white/20 mx-2"></div>

        <!-- Open Windows -->
        <div class="flex gap-2 flex-1">
          <%= for {window_id, window} <- @windows do %>
            <button
              phx-click="restore_window"
              phx-value-window-id={window_id}
              phx-target={@myself}
              class={"px-4 py-2 rounded-lg text-white text-sm transition-all #{if @active_window == window_id and not window.minimized, do: "bg-purple-600/50 border border-purple-500/50", else: "bg-white/10 hover:bg-white/20"}"}
            >
              <%= window.title %>
            </button>
          <% end %>
        </div>

        <!-- Clock -->
        <div class="text-white/60 text-sm font-mono">
          <%= Calendar.strftime(DateTime.utc_now(), "%H:%M") %>
        </div>
      </div>
    </div>
    """
  end

  defp desktop_icon(assigns) do
    ~H"""
    <button
      phx-click="open_app"
      phx-value-app={@icon}
      phx-target={@target}
      class="desktop-icon flex flex-col items-center gap-2 p-3 rounded-xl hover:bg-white/10 transition-all cursor-pointer group"
    >
      <div class="w-14 h-14 bg-gradient-to-br from-purple-600/50 to-violet-600/50 rounded-xl flex items-center justify-center border border-purple-500/30 group-hover:border-purple-500/60 transition-all shadow-lg">
        <%= case @icon do %>
          <% "notepad" -> %>
            <svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
            </svg>
          <% "snake" -> %>
            <svg class="w-8 h-8 text-white" fill="currentColor" viewBox="0 0 24 24">
              <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/>
            </svg>
          <% "minesweeper" -> %>
            <svg class="w-8 h-8 text-white" fill="currentColor" viewBox="0 0 24 24">
              <circle cx="12" cy="12" r="10" fill="none" stroke="currentColor" stroke-width="2"/>
              <circle cx="12" cy="12" r="3"/>
              <line x1="12" y1="2" x2="12" y2="6" stroke="currentColor" stroke-width="2"/>
              <line x1="12" y1="18" x2="12" y2="22" stroke="currentColor" stroke-width="2"/>
              <line x1="2" y1="12" x2="6" y2="12" stroke="currentColor" stroke-width="2"/>
              <line x1="18" y1="12" x2="22" y2="12" stroke="currentColor" stroke-width="2"/>
            </svg>
          <% "calculator" -> %>
            <svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 14h.01M12 14h.01M15 11h.01M12 11h.01M9 11h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z" />
            </svg>
          <% _ -> %>
            <div class="w-8 h-8 bg-white/20 rounded"></div>
        <% end %>
      </div>
      <span class="text-white text-xs font-medium drop-shadow-lg"><%= @label %></span>
    </button>
    """
  end

  defp window(assigns) do
    ~H"""
    <div
      id={@window.id}
      phx-click="focus_window"
      phx-value-window-id={@window.id}
      phx-target={@myself}
      class={"window absolute bg-gray-900/95 backdrop-blur-xl rounded-xl border shadow-2xl overflow-hidden transition-opacity #{if @window.minimized, do: "opacity-0 pointer-events-none", else: "opacity-100"} #{if @active, do: "border-purple-500/50", else: "border-white/20"}"}
      style={"left: #{@window.x}px; top: #{@window.y}px; width: #{@window.width}px; height: #{@window.height}px; z-index: #{@window.z_index};"}
      phx-hook="Draggable"
    >
      <!-- Title Bar -->
      <div class="window-titlebar h-10 bg-black/50 flex items-center justify-between px-4 cursor-move">
        <span class="text-white text-sm font-medium"><%= @window.title %></span>
        <div class="flex gap-2">
          <button
            phx-click="minimize_window"
            phx-value-window-id={@window.id}
            phx-target={@myself}
            class="w-4 h-4 rounded-full bg-yellow-500 hover:bg-yellow-400 transition-colors"
          ></button>
          <button
            phx-click="close_window"
            phx-value-window-id={@window.id}
            phx-target={@myself}
            class="w-4 h-4 rounded-full bg-red-500 hover:bg-red-400 transition-colors"
          ></button>
        </div>
      </div>

      <!-- Content -->
      <div class="window-content h-[calc(100%-2.5rem)] overflow-auto">
        <%= case @window.app do %>
          <% "notepad" -> %>
            <.notepad_app content={@notepad_content} myself={@myself} />
          <% "snake" -> %>
            <.snake_app game={@snake_game} myself={@myself} />
          <% "minesweeper" -> %>
            <.minesweeper_app game={@minesweeper_game} myself={@myself} />
          <% "calculator" -> %>
            <.calculator_app display={@calculator_display} myself={@myself} />
          <% _ -> %>
            <div class="p-4 text-white">Application non trouvée</div>
        <% end %>
      </div>
    </div>
    """
  end

  defp notepad_app(assigns) do
    ~H"""
    <div class="h-full flex flex-col">
      <div class="bg-gray-800/50 px-3 py-1 text-xs text-white/60 border-b border-white/10">
        Fichier | Édition | Format | Aide
      </div>
      <textarea
        phx-change="notepad_change"
        phx-target={@myself}
        name="content"
        class="flex-1 w-full bg-gray-950 text-white/90 p-4 font-mono text-sm resize-none focus:outline-none"
        placeholder="Écrivez ici..."
      ><%= @content %></textarea>
    </div>
    """
  end

  defp snake_app(assigns) do
    ~H"""
    <div class="h-full flex flex-col items-center justify-center p-4 bg-gray-950">
      <div class="mb-4 flex items-center gap-4">
        <span class="text-white font-bold">Score: <%= @game.score %></span>
        <%= if @game.game_over do %>
          <span class="text-red-500 font-bold">GAME OVER!</span>
        <% end %>
      </div>

      <div
        id="snake-board"
        phx-hook="SnakeGame"
        phx-target={@myself}
        data-running={to_string(@game.running)}
        data-game-over={to_string(@game.game_over)}
        class="relative bg-gray-900 border-2 border-purple-500/50 rounded-lg"
        style="width: 400px; height: 400px;"
        tabindex="0"
      >
        <%= for {x, y} <- @game.snake do %>
          <div
            class="absolute bg-gradient-to-br from-green-500 to-green-600 rounded-sm"
            style={"left: #{x * 20}px; top: #{y * 20}px; width: 18px; height: 18px;"}
          ></div>
        <% end %>

        <div
          class="absolute bg-red-500 rounded-full animate-pulse"
          style={"left: #{elem(@game.food, 0) * 20 + 2}px; top: #{elem(@game.food, 1) * 20 + 2}px; width: 14px; height: 14px;"}
        ></div>
      </div>

      <div class="mt-4 flex gap-2">
        <%= if not @game.running do %>
          <button
            phx-click="snake_start"
            phx-target={@myself}
            class="px-4 py-2 bg-purple-600 hover:bg-purple-700 text-white rounded-lg font-medium transition-colors"
          >
            <%= if @game.game_over, do: "Rejouer", else: "Démarrer" %>
          </button>
        <% end %>
        <button
          phx-click="snake_reset"
          phx-target={@myself}
          class="px-4 py-2 bg-gray-700 hover:bg-gray-600 text-white rounded-lg font-medium transition-colors"
        >
          Reset
        </button>
      </div>

      <div class="mt-4 text-white/40 text-xs">
        Utilisez les flèches du clavier pour diriger le serpent
      </div>
    </div>
    """
  end

  defp minesweeper_app(assigns) do
    ~H"""
    <div class="h-full flex flex-col items-center p-4 bg-gray-950">
      <div class="mb-4 flex items-center gap-4">
        <span class="text-white font-bold">Mines: <%= @game.mines - MapSet.size(@game.flagged) %></span>
        <%= if @game.game_over do %>
          <span class="text-red-500 font-bold">BOOM!</span>
        <% end %>
        <%= if @game.won do %>
          <span class="text-green-500 font-bold">GAGNÉ!</span>
        <% end %>
      </div>

      <div class="grid gap-0.5 bg-gray-800 p-2 rounded-lg">
        <%= for y <- 0..(@game.size - 1) do %>
          <div class="flex gap-0.5">
            <%= for x <- 0..(@game.size - 1) do %>
              <% cell = Map.get(@game.board, {x, y}) %>
              <% revealed = MapSet.member?(@game.revealed, {x, y}) %>
              <% flagged = MapSet.member?(@game.flagged, {x, y}) %>
              <button
                phx-click="minesweeper_reveal"
                phx-value-x={x}
                phx-value-y={y}
                phx-target={@myself}
                phx-click-away="minesweeper_flag"
                oncontextmenu={"event.preventDefault(); document.querySelector('[phx-target]').dispatchEvent(new CustomEvent('phx:minesweeper_flag', {detail: {x: #{x}, y: #{y}}}))"}
                class={"w-7 h-7 flex items-center justify-center text-sm font-bold rounded transition-all #{cond do
                  revealed and cell.mine -> "bg-red-600"
                  revealed -> "bg-gray-600"
                  flagged -> "bg-yellow-600"
                  true -> "bg-purple-600/50 hover:bg-purple-600/70"
                end}"}
              >
                <%= cond do %>
                  <% flagged and not revealed -> %>
                    <span class="text-white">🚩</span>
                  <% revealed and cell.mine -> %>
                    <span>💣</span>
                  <% revealed and cell.adjacent > 0 -> %>
                    <span class={"#{get_number_color(cell.adjacent)}"}><%= cell.adjacent %></span>
                  <% true -> %>
                    <span></span>
                <% end %>
              </button>
            <% end %>
          </div>
        <% end %>
      </div>

      <div class="mt-4 flex gap-2">
        <button
          phx-click="minesweeper_reset"
          phx-target={@myself}
          class="px-4 py-2 bg-purple-600 hover:bg-purple-700 text-white rounded-lg font-medium transition-colors"
        >
          Nouvelle partie
        </button>
      </div>

      <div class="mt-2 text-white/40 text-xs">
        Clic gauche = révéler | Clic droit = drapeau
      </div>
    </div>
    """
  end

  defp get_number_color(num) do
    case num do
      1 -> "text-blue-400"
      2 -> "text-green-400"
      3 -> "text-red-400"
      4 -> "text-purple-400"
      5 -> "text-yellow-400"
      6 -> "text-cyan-400"
      7 -> "text-pink-400"
      8 -> "text-gray-400"
      _ -> "text-white"
    end
  end

  attr :click, :string, required: true
  attr :myself, :any, required: true
  attr :value, :string, default: nil
  attr :class, :string, default: ""
  slot :inner_block, required: true

  defp calc_btn(assigns) do
    event_value = case assigns.click do
      "calc_digit" -> [{"phx-value-digit", assigns.value}]
      "calc_operation" -> [{"phx-value-op", assigns.value}]
      _ -> []
    end

    assigns = assign(assigns, :event_value, event_value)

    ~H"""
    <button
      phx-click={@click}
      phx-target={@myself}
      {@event_value}
      class={"text-white text-xl font-semibold rounded-lg py-3 transition-all bg-white/10 hover:bg-white/20 #{@class}"}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  defp calculator_app(assigns) do
    ~H"""
    <div class="h-full flex flex-col p-4 bg-gray-950">
      <!-- Display -->
      <div class="bg-gray-800 rounded-lg p-4 mb-4">
        <div class="text-right text-white text-3xl font-mono overflow-hidden">
          <%= @display %>
        </div>
      </div>

      <!-- Buttons -->
      <div class="grid grid-cols-4 gap-2 flex-1">
        <.calc_btn click="calc_clear" myself={@myself} class="bg-red-600 hover:bg-red-700 col-span-2">AC</.calc_btn>
        <.calc_btn click="calc_operation" value="/" myself={@myself} class="bg-purple-600 hover:bg-purple-700">÷</.calc_btn>
        <.calc_btn click="calc_operation" value="*" myself={@myself} class="bg-purple-600 hover:bg-purple-700">×</.calc_btn>

        <.calc_btn click="calc_digit" value="7" myself={@myself}>7</.calc_btn>
        <.calc_btn click="calc_digit" value="8" myself={@myself}>8</.calc_btn>
        <.calc_btn click="calc_digit" value="9" myself={@myself}>9</.calc_btn>
        <.calc_btn click="calc_operation" value="-" myself={@myself} class="bg-purple-600 hover:bg-purple-700">−</.calc_btn>

        <.calc_btn click="calc_digit" value="4" myself={@myself}>4</.calc_btn>
        <.calc_btn click="calc_digit" value="5" myself={@myself}>5</.calc_btn>
        <.calc_btn click="calc_digit" value="6" myself={@myself}>6</.calc_btn>
        <.calc_btn click="calc_operation" value="+" myself={@myself} class="bg-purple-600 hover:bg-purple-700">+</.calc_btn>

        <.calc_btn click="calc_digit" value="1" myself={@myself}>1</.calc_btn>
        <.calc_btn click="calc_digit" value="2" myself={@myself}>2</.calc_btn>
        <.calc_btn click="calc_digit" value="3" myself={@myself}>3</.calc_btn>
        <.calc_btn click="calc_equals" myself={@myself} class="bg-green-600 hover:bg-green-700 row-span-2">=</.calc_btn>

        <.calc_btn click="calc_digit" value="0" myself={@myself} class="col-span-2">0</.calc_btn>
        <.calc_btn click="calc_decimal" myself={@myself}>.</.calc_btn>
      </div>
    </div>
    """
  end
end
