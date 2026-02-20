defmodule ShdxwWeb.Components.ShdxwOS do
  use ShdxwWeb, :live_component

  alias ShdxwWeb.Helpers.Cipher

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> assign(:windows, %{})
     |> assign(:active_window, nil)
     |> assign(:z_index_counter, 1)
     |> assign(:start_menu_open, false)
     |> assign(
       :notepad_content,
       Cipher.decode!(
         "ᚲᚾ᛬ᚹᚦ᛬ᚹᛉ᛬ᚹᚲ᛬ᚷᛈ᛬ᚹᛉ᛬ᚹᚲ᛬ᚷᛉ᛬ᚹᛉ᛫ᚷᚺ᛬ᚷᛉ᛬ᚷᚾ᛫ᚱᚺ᛬ᚲᚨ᛬ᚲᛊ᛬ᚱᚨ᛬ᚱᛇ᛫ᚲᚱ᛬ᚱᚺ᛬ᚨᛁ᛬ᚢᚢ᛬ᚢᚢ᛬ᚲᚺ᛬ᚹᛉ᛬ᚹᚺ᛬ᚹᚦ᛫ᚹᛉ᛬ᚷᚺ᛬ᚷᛊ᛫ᚷᛉ᛬ᚹᚲ᛫ᚹᚲ᛬ᚹᚱ᛬ᚷᛊ᛬ᚹᛉ᛬ᚷᛃ᛬ᚹᛁ᛬ᚹᛊ᛬ᚨᚲ᛫ᚱᛈ᛬ᚹᚱ᛬ᚷᛉ᛬ᚷᚺ᛫ᚷᛃ᛬ᚹᚱ᛬ᚷᛉ᛬ᚷᛈ᛬ᚹᛉ᛬ᚷᚢ᛫ᛈᚺ᛬ᛃᚦ᛬ᚹᚺ᛬ᚷᚾ᛬ᚹᚦ᛬ᚷᚾ᛬ᚹᛉ᛫ᚹᚺ᛬ᚹᛉ᛫ᚷᛁ᛬ᚷᛉ᛬ᚹᛉ᛫ᚷᛈ᛬ᚹᚱ᛬ᚷᛉ᛬ᚷᚺ᛫ᚷᛈ᛬ᚹᚱ᛬ᚷᛉ᛬ᚹᚹ᛬ᚹᛉ᛬ᚷᚢ᛫ᚹᚦ᛬ᚹᚺ᛬ᚹᚦ᛬ᚨᚲ᛬ᚲᛉ᛬ᚷᚺ᛬ᚷᚺ᛬ᚹᛁ᛬ᚷᚦ᛬ᚹᛉ᛬ᚷᚢ᛫ᚹᚹ᛬ᚹᛉ᛫ᚱᚺ᛬ᚹᚲ᛬ᚹᛁ᛬ᚹᚠ᛬ᚹᛉ᛬ᚨᛁ᛫ᚲᚢ᛬ᚹᚱ᛬ᚷᛉ᛬ᚹᛉ᛬ᚷᚢ᛫ᚹᛁ᛬ᚷᛉ᛫ᚲᛊ᛬ᛈᚺ᛬ᛃᚦ᛬ᚹᚷ᛬ᚹᚦ᛬ᚹᚲ᛬ᚹᛉ᛬ᚷᛉ᛬ᚷᚾ᛬ᚨᛁ᛫ᚲᛉ᛬ᚷᚨ᛬ᚷᛃ᛬ᚹᚹ᛬ᚹᚱ᛬ᚷᚾ᛬ᚹᛉ᛬ᚷᚢ᛫ᚹᚹ᛬ᚹᛉ᛬ᚷᚺ᛫ᚹᛁ᛬ᚷᛃ᛬ᚷᛃ᛬ᚹᚹ᛬ᚹᚦ᛬ᚹᚺ᛬ᚹᛁ᛬ᚷᛊ᛬ᚹᚦ᛬ᚹᚱ᛬ᚹᚲ᛬ᚷᚺ᛬ᚨᚲ᛬ᚨᚲ᛬ᚨᚲ"
       )
     )
     |> assign(:snake_game, init_snake_game())
     |> assign(:minesweeper_game, init_minesweeper_game())
     |> assign(:calculator_display, "0")
     |> assign(:calculator_memory, nil)
     |> assign(:calculator_operation, nil)
     |> assign(:calculator_new_number, true)
     |> assign(
       :warez_content,
       Cipher.decode!(
         "ᚢᚢ᛬ᚱᚠ᛫ᚱᛇ᛬ᚲᛁ᛬ᚱᚾ᛬ᚲᛉ᛬ᚱᚢ᛫ᚱᛊ᛬ᚲᛉ᛬ᚱᚾ᛬ᚲᚷ᛬ᚲᚦ᛬ᚲᚲ᛬ᚲᛁ᛬ᚲᚹ᛫ᚷᛈ᛬ᚦᛃ᛬ᚨᚲ᛬ᚦᛇ᛬ᚨᚲ᛬ᚦᚺ᛫ᚱᚷ᛬ᚢᚢ᛬ᚱᚠ᛫ᚲᚺ᛬ᚲᚱ᛬ᚲᚲ᛬ᚲᚲ᛬ᚲᛉ᛬ᚲᚺ᛬ᚱᛊ᛬ᚲᚦ᛬ᚲᚱ᛬ᚲᚲ᛫ᚲᛉ᛬ᚱᚺ᛬ᚱᛊ᛬ᚲᛁ᛬ᚲᚾ᛬ᚲᚹ᛬ᚲᚦ᛬ᚱᚺ᛬ᚲᚨ᛬ᚲᛉ᛬ᚲᛊ᛫ᚱᚷ᛬ᚢᚢ᛬ᚱᚠ᛫ᚲᛉ᛬ᚲᚲ᛬ᚲᚺ᛬ᚱᚾ᛬ᚱᚦ᛬ᚱᛃ᛬ᚱᛊ᛬ᚲᛉ᛬ᚲᛊ᛫ᚲᚺ᛬ᚲᚨ᛬ᚲᛁ᛬ᚲᚲ᛬ᚲᚲ᛬ᚲᛉ᛬ᚲᚹ᛫ᚲᛁ᛬ᚲᚺ᛬ᚱᛊ᛬ᚲᚦ᛬ᚱᛈ᛬ᚲᛉ᛫ᚱᚷ᛬ᚢᚢ᛬ᚦᚲ᛫ᚱᛇ᛬ᚹᛉ᛬ᚹᚹ᛬ᚹᚺ᛬ᚹᚱ᛬ᚹᚷ᛬ᚹᛉ᛫ᚷᛊ᛬ᚹᚱ᛫ᚱᚺ᛬ᚲᚨ᛬ᚲᛊ᛬ᚱᚨ᛬ᚱᛇ᛬ᚨᛇ᛬ᚷᚺ᛫ᚲᚲ᛬ᚹᛉ᛬ᚷᛊ᛬ᚷᛇ᛬ᚹᚱ᛬ᚷᚾ᛬ᚹᚠ᛬ᚢᚢ᛬ᚦᚲ᛫ᚱᛊ᛬ᚹᚨ᛬ᚹᚦ᛬ᚷᚺ᛫ᚷᛊ᛬ᚹᛉ᛬ᚷᚾ᛬ᚹᚷ᛬ᚹᚦ᛬ᚹᚲ᛬ᚹᛁ᛬ᚹᚹ᛫ᚹᚦ᛬ᚷᚺ᛫ᚷᚾ᛬ᚹᛉ᛬ᚷᚺ᛬ᚹᛉ᛬ᚷᚾ᛬ᚷᛈ᛬ᚹᛉ᛬ᚹᛊ᛫ᚹᛈ᛬ᚹᚱ᛬ᚷᚾ᛫ᚹᛁ᛬ᚷᛉ᛬ᚷᛊ᛬ᚹᚨ᛬ᚹᚱ᛬ᚷᚾ᛬ᚹᚦ᛬ᚷᚢ᛬ᚹᛉ᛬ᚹᛊ᛫ᚹᚱ᛬ᚷᛃ᛬ᚹᛉ᛬ᚷᚾ᛬ᚹᛁ᛬ᚷᛊ᛬ᚹᚱ᛬ᚷᚾ᛬ᚷᚺ᛬ᚨᚲ᛬ᚢᚢ᛬ᚦᚲ᛫ᚲᛁ᛬ᚹᚲ᛬ᚷᚦ᛫ᚷᛉ᛬ᚹᚲ᛬ᚹᛁ᛬ᚷᛉ᛬ᚷᛊ᛬ᚹᚨ᛬ᚹᚱ᛬ᚷᚾ᛬ᚹᚦ᛬ᚷᚢ᛬ᚹᛉ᛬ᚹᛊ᛫ᚹᛁ᛬ᚹᚺ᛬ᚹᚺ᛬ᚹᛉ᛬ᚷᚺ᛬ᚷᚺ᛫ᚹᛁ᛬ᚷᛊ᛬ᚷᛊ᛬ᚹᛉ᛬ᚹᚷ᛬ᚷᛃ᛬ᚷᛊ᛫ᚷᛇ᛬ᚹᚦ᛬ᚹᚹ᛬ᚹᚹ᛫ᚹᚾ᛬ᚹᛉ᛫ᚷᛊ᛬ᚷᚾ᛬ᚹᛁ᛬ᚹᚺ᛬ᚹᛉ᛬ᚹᛊ᛬ᚨᚲ᛬ᚢᚢ᛬ᚢᚢ᛬ᚨᚷ᛬ᚨᚷ᛬ᚨᚷ᛬ᚢᚢ᛬ᚢᚢ᛬ᚱᚺ᛬ᚱᛊ᛬ᚲᛁ᛬ᚱᛊ᛬ᚱᛉ᛬ᚱᚺ᛬ᚦᚢ᛫ᚲᚱ᛬ᚲᚲ᛬ᚲᚹ᛬ᚲᚦ᛬ᚲᚲ᛬ᚲᛉ᛬ᚢᚢ᛬ᚲᚲ᛬ᚲᚱ᛬ᚲᛊ᛬ᚲᛉ᛬ᚦᚢ᛫ᚷᚺ᛬ᚹᚨ᛬ᚹᛊ᛬ᚷᚨ᛬ᚷᛇ᛬ᚨᚷ᛬ᚷᚾ᛬ᚹᛉ᛬ᚹᚹ᛬ᚹᛁ᛬ᚷᚦ᛬ᚨᚷ᛬ᚦᛃ᛬ᚦᛇ᛬ᚢᚢ᛬ᚱᛃ᛬ᚱᚾ᛬ᚲᚱ᛬ᚱᛊ᛬ᚲᚱ᛬ᚲᚺ᛬ᚲᚱ᛬ᚲᚹ᛬ᚦᚢ᛫ᚲᚷ᛬ᚱᛊ᛬ᚲᚾ᛬ᚨᚷ᛬ᚲᚺ᛬ᚲᚦ᛬ᚱᛃ᛬ᚲᚨ᛬ᚲᛉ᛬ᚱᚾ᛬ᚨᚱ᛬ᚷᛈ᛬ᚦᚾ᛬ᚢᚢ᛬ᚲᚹ᛬ᚲᛁ᛬ᚱᛊ᛬ᚲᛉ᛬ᚲᚲ᛬ᚲᚺ᛬ᚱᚦ᛬ᚦᚢ᛫ᚦᚾ᛬ᚦᛇ᛬ᚹᚷ᛬ᚷᚺ᛬ᚢᚢ᛬ᚱᛉ᛬ᚱᚺ᛬ᚲᛉ᛬ᚱᚾ᛬ᚦᚢ᛫ᚱᚺ᛬ᚹᚺ᛬ᚹᚱ᛬ᚷᛊ᛬ᚷᛊ᛬ᚢᚢ᛬ᚢᚢ᛬ᚦᚲ᛫ᚲᛁ᛬ᚷᚾ᛬ᚹᛉ᛫ᚷᚦ᛬ᚹᚱ᛬ᚷᛉ᛫ᚷᚺ᛬ᚷᛉ᛬ᚷᚾ᛬ᚹᛉ᛫ᚷᚦ᛬ᚹᚱ᛬ᚷᛉ᛫ᚷᛇ᛬ᚹᛁ᛬ᚹᚲ᛬ᚷᛊ᛫ᚷᛊ᛬ᚹᚱ᛫ᚹᛇ᛬ᚹᚱ᛫ᚷᛊ᛬ᚹᚨ᛬ᚷᚾ᛬ᚹᚱ᛬ᚷᛉ᛬ᚹᛇ᛬ᚹᚨ᛫ᚷᛇ᛬ᚹᚦ᛬ᚷᛊ᛬ᚹᚨ᛫ᚷᛊ᛬ᚹᚨ᛬ᚹᚦ᛬ᚷᚺ᛬ᚦᚱ᛫ᚲᚦ᛬ᛊᚾ᛬ᚾᛃ᛬ᚺᚦ᛬ᚹᚷ᛫ᚹᚢ᛬ᚷᛉ᛬ᚷᚺ᛬ᚷᛊ᛫ᚷᚺ᛬ᚹᛁ᛬ᚷᚦ᛬ᚹᚦ᛬ᚹᚲ᛬ᚹᛇ᛬ᚨᚹ᛫ᚲᚦ᛫ᚷᛇ᛬ᚹᛁ᛬ᚷᚺ᛫ᚹᚺ᛬ᚷᛉ᛬ᚷᚾ᛬ᚹᚦ᛬ᚹᚱ᛬ᚷᛉ᛬ᚷᚺ᛫ᚷᛊ᛬ᚹᚱ᛬ᚹᚱ᛬ᚨᚹ᛫ᚹᚾ᛬ᚷᛉ᛬ᚷᛊ᛫ᚷᛊ᛬ᚹᚨ᛬ᚹᛉ᛬ᚷᚦ᛫ᚹᚷ᛬ᚹᛁ᛬ᚹᛊ᛬ᚹᛉ᛫ᚹᚷ᛬ᚹᛉ᛫ᚷᚾ᛬ᚹᛉ᛬ᚹᛁ᛬ᚹᚹ᛬ᚹᚦ᛬ᚷᚢ᛬ᚹᛉ᛫ᚷᛃ᛬ᚷᚾ᛬ᚹᛉ᛬ᚷᛊ᛬ᚷᛊ᛬ᚷᚦ᛫ᚹᛈ᛬ᚹᛁ᛬ᚷᚺ᛬ᚷᛊ᛫ᚷᛊ᛬ᚹᚨ᛬ᚹᛁ᛬ᚷᛊ᛫ᚲᚦ᛫ᚷᛇ᛬ᚹᛁ᛬ᚷᚺ᛫ᚹᛇ᛬ᚹᚱ᛬ᚹᚦ᛬ᚹᚲ᛬ᚹᛇ᛫ᚷᛊ᛬ᚹᚱ᛬ᚹᚱ᛫ᚹᛈ᛬ᚹᛁ᛬ᚷᚾ᛬ᚨᚲ᛫ᚱᚾ᛬ᚹᛉ᛬ᚷᚺ᛬ᚷᛉ᛬ᚹᚹ᛬ᚷᛊ᛫ᚹᚦ᛬ᚷᚺ᛬ᚦᚢ᛫ᚲᚦ᛫ᚹᛁ᛬ᚹᚷ᛫ᚷᛇ᛬ᚹᚨ᛬ᚹᛉ᛬ᚷᚾ᛬ᚹᛉ᛫ᚲᚦ᛫ᚹᛁ᛬ᚹᚷ᛫ᚷᛊ᛬ᚹᚱ᛬ᚹᛊ᛬ᚹᛁ᛬ᚷᚦ᛬ᚨᚹ᛫ᚷᛇ᛬ᚹᚦ᛬ᚷᛊ᛬ᚹᚨ᛫ᚹᛁ᛫ᚹᚨ᛬ᚹᛉ᛬ᚹᛁ᛬ᚷᛈ᛬ᚷᚦ᛫ᚷᚺ᛬ᚹᛉ᛬ᚹᚺ᛬ᚷᚾ᛬ᚹᛉ᛬ᚷᛊ᛫ᚲᚦ᛫ᚹᚠ᛬ᚹᛉ᛬ᚹᛉ᛬ᚷᛃ᛫ᚹᛊ᛬ᚹᛉ᛬ᚹᛉ᛬ᚷᛃ᛫ᚹᚦ᛬ᚹᚲ᛬ᚷᚺ᛬ᚹᚦ᛬ᚹᛊ᛬ᚹᛉ᛬ᛊᚾ᛬ᚾᛃ᛬ᚺᛊ᛬ᚹᛁ᛬ᚹᚲ᛬ᚹᛊ᛫ᚹᚦ᛬ᚹᛈ᛫ᚲᚦ᛫ᚷᚾ᛬ᚹᛉ᛬ᚷᛈ᛬ᚹᛉ᛬ᚹᛁ᛬ᚹᚹ᛫ᚹᚦ᛬ᚷᛊ᛬ᚨᚹ᛫ᚷᛊ᛬ᚹᚨ᛬ᚹᛉ᛬ᚷᚦ᛬ᛊᚾ᛬ᚾᛃ᛬ᚺᚦ᛬ᚹᚹ᛬ᚹᚹ᛫ᚹᛈ᛬ᚹᚦ᛬ᚹᚲ᛬ᚹᛊ᛫ᚹᚷ᛬ᚹᛉ᛬ᚨᚲ᛫ᚲᚦ᛫ᚹᛊ᛬ᚹᚦ᛬ᚹᛊ᛬ᚹᚲ᛬ᚨᛇ᛬ᚷᛊ᛫ᚷᛊ᛬ᚹᚨ᛬ᚹᚦ᛬ᚹᚲ᛬ᚹᚠ᛫ᚷᛊ᛬ᚹᚨ᛬ᚹᛉ᛬ᚷᚦ᛫ᚷᛇ᛬ᚹᛉ᛬ᚷᚾ᛬ᚹᛉ᛫ᚹᚺ᛬ᚹᛁ᛬ᚷᛃ᛬ᚹᛁ᛬ᚹᚾ᛬ᚹᚹ᛬ᚹᛉ᛫ᚹᚱ᛬ᚹᛈ᛫ᚹᚦ᛬ᚷᛊ᛬ᚨᚹ᛫ᚹᚾ᛬ᚷᛉ᛬ᚷᛊ᛫ᚷᛊ᛬ᚹᚨ᛬ᚹᛉ᛬ᚷᚦ᛫ᚹᛁ᛬ᚷᚾ᛬ᚹᛉ᛫ᚹᚷ᛬ᚷᛉ᛬ᚹᚺ᛬ᚹᚨ᛫ᚷᚺ᛬ᚷᛊ᛬ᚷᚾ᛬ᚹᚱ᛬ᚹᚲ᛬ᚹᛇ᛬ᚹᛉ᛬ᚷᚾ᛫ᚷᛊ᛬ᚹᚨ᛬ᚹᛁ᛬ᚹᚲ᛫ᚲᚦ᛫ᚷᛊ᛬ᚹᚨ᛬ᚹᚱ᛬ᚷᛉ᛬ᚹᛇ᛬ᚹᚨ᛬ᚷᛊ᛬ᚨᚲ᛬ᚨᚲ᛬ᚨᚲ᛬ᚢᚢ᛬ᚢᚢ᛬ᚦᚲ᛫ᚦᛃ᛬ᚦᚨ᛬ᚨᚱ᛬ᚦᛁ᛬ᚦᛊ᛬ᚨᚱ᛬ᚦᚾ᛬ᚦᛃ᛬ᚦᛁ᛬ᚦᚨ᛫ᚱᚠ᛬ᚷᚾ᛬ᚹᛉ᛬ᚷᚺ᛬ᚷᛊ᛬ᚹᚱ᛬ᚷᚾ᛬ᚹᛉ᛬ᚹᛊ᛫ᚷᚺ᛬ᚹᛉ᛬ᚷᚺ᛬ᚷᚺ᛬ᚹᚦ᛬ᚹᚱ᛬ᚹᚲ᛬ᚱᚷ᛬ᚢᚢ᛬ᚦᚲ᛫ᚱᛇ᛬ᚹᚨ᛬ᚹᛉ᛬ᚹᚲ᛫ᚷᚦ᛬ᚹᚱ᛬ᚷᛉ᛫ᚷᛊ᛬ᚹᚨ᛬ᚹᚦ᛬ᚹᚲ᛬ᚹᚠ᛫ᚹᛁ᛬ᚹᚾ᛬ᚹᚱ᛬ᚷᛉ᛬ᚷᛊ᛫ᚹᚦ᛬ᚷᛊ᛬ᚨᚹ᛫ᚲᛉ᛬ᚲᚷ᛬ᚱᛃ᛬ᚱᚾ᛬ᚲᛉ᛬ᚱᚺ᛬ᚱᚺ᛫ᚹᚦ᛬ᚷᚺ᛬ᚹᚲ᛬ᚨᛇ᛬ᚷᛊ᛫ᚷᛊ᛬ᚹᚨ᛬ᚹᛁ᛬ᚷᛊ᛫ᚹᚺ᛬ᚷᚾ᛬ᚹᛁ᛬ᚷᚢ᛬ᚷᚦ᛬ᚨᚲ᛬ᚨᚲ᛬ᚨᚲ᛫ᚱᛊ᛬ᚹᚨ᛬ᚹᛉ᛫ᚷᛃ᛬ᚷᚾ᛬ᚹᛉ᛬ᚷᚺ᛬ᚷᚺ᛬ᚷᛉ᛬ᚷᚾ᛬ᚹᛉ᛫ᚹᛈ᛬ᚷᚾ᛬ᚹᚱ᛬ᚹᚷ᛫ᚷᛊ᛬ᚹᚨ᛬ᚹᛉ᛫ᚹᚨ᛬ᚹᛉ᛬ᚹᛁ᛬ᚷᛈ᛬ᚷᚦ᛫ᚹᚨ᛬ᚹᚦ᛬ᚷᛊ᛬ᚷᛊ᛬ᚹᛉ᛬ᚷᚾ᛬ᚷᚺ᛫ᚹᚷ᛬ᚹᛁ᛬ᚹᛊ᛬ᚹᛉ᛫ᚹᚨ᛬ᚹᛉ᛬ᚷᚾ᛫ᚹᚺ᛬ᚷᚾ᛬ᚹᛁ᛬ᚹᚺ᛬ᚹᚠ᛬ᚨᚲ᛫ᚲᚦ᛫ᚹᚨ᛬ᚹᚱ᛬ᚷᛃ᛬ᚹᛉ᛫ᚷᚺ᛬ᚹᚨ᛬ᚹᛉ᛬ᛊᚾ᛬ᚾᛃ᛬ᚺᚦ᛬ᚹᚹ᛬ᚹᚹ᛫ᚹᚺ᛬ᚹᚱ᛬ᚹᚲ᛬ᚷᛊ᛬ᚹᚦ᛬ᚹᚲ᛬ᚷᛉ᛬ᚹᛉ᛫ᚷᛊ᛬ᚹᚱ᛫ᚹᛊ᛬ᚹᚱ᛫ᚷᛇ᛬ᚹᚨ᛬ᚹᛁ᛬ᚷᛊ᛫ᚷᚺ᛬ᚹᚨ᛬ᚹᛉ᛬ᛊᚾ᛬ᚾᛃ᛬ᚺᚦ᛬ᚷᚺ᛫ᚹᛁ᛬ᚹᚹ᛬ᚷᛇ᛬ᚹᛁ᛬ᚷᚦ᛬ᚷᚺ᛫ᚹᚠ᛬ᚹᚲ᛬ᚹᚱ᛬ᚷᛇ᛬ᚹᚲ᛫ᚹᚨ᛬ᚹᚱ᛬ᚷᛇ᛫ᚷᛊ᛬ᚹᚱ᛫ᚹᛊ᛬ᚹᚱ᛫ᚹᚦ᛬ᚹᚲ᛫ᚷᛊ᛬ᚹᚨ᛬ᚹᛉ᛫ᚹᛈ᛬ᚷᛉ᛬ᚷᛊ᛬ᚷᛉ᛬ᚷᚾ᛬ᚹᛉ᛬ᚨᚲ᛫ᚱᚺ᛬ᚹᚱ᛬ᚹᚷ᛬ᚹᛉ᛬ᚷᛊ᛬ᚹᚦ᛬ᚹᚷ᛬ᚹᛉ᛬ᚷᚺ᛫ᚷᛊ᛬ᚹᚨ᛬ᚹᛉ᛫ᚷᚺ᛬ᚷᛊ᛬ᚹᚱ᛬ᚷᚾ᛬ᚹᚦ᛬ᚹᛉ᛬ᚷᚺ᛫ᚹᛁ᛬ᚷᚾ᛬ᚹᛉ᛫ᚹᛁ᛬ᚹᚹ᛬ᚷᚾ᛬ᚹᛉ᛬ᚹᛁ᛬ᚹᛊ᛬ᚷᚦ᛫ᚷᛇ᛬ᚷᚾ᛬ᚹᚦ᛬ᚷᛊ᛬ᚷᛊ᛬ᚹᛉ᛬ᚹᚲ᛬ᚦᚠ᛫ᚷᚺ᛬ᚹᚱ᛬ᚹᚷ᛬ᚹᛉ᛬ᚷᛊ᛬ᚹᚦ᛬ᚹᚷ᛬ᚹᛉ᛬ᚷᚺ᛫ᚷᛊ᛬ᚹᚨ᛬ᚹᛉ᛫ᚹᚺ᛬ᚹᚱ᛬ᚹᚷ᛬ᚹᚷ᛬ᚷᛉ᛬ᚹᚲ᛬ᚹᚦ᛬ᚷᛊ᛬ᚷᚦ᛫ᚹᚹ᛬ᚹᚱ᛬ᚷᛈ᛬ᚹᛉ᛬ᚷᚺ᛫ᚹᚦ᛬ᚷᛊ᛫ᚷᚺ᛬ᚹᚱ᛫ᚹᚷ᛬ᚷᛉ᛬ᚹᚺ᛬ᚹᚨ᛫ᚷᛊ᛬ᚹᚨ᛬ᚹᛁ᛬ᚷᛊ᛫ᚹᚦ᛬ᚷᛊ᛫ᚷᛇ᛬ᚷᚾ᛬ᚹᚦ᛬ᚷᛊ᛬ᚹᛉ᛬ᚷᚺ᛫ᚹᚦ᛬ᚷᛊ᛬ᚷᚺ᛬ᚹᛉ᛬ᚹᚹ᛬ᚹᛈ᛫ᚹᛈ᛬ᚹᚱ᛬ᚷᚾ᛫ᚷᛊ᛬ᚹᚨ᛬ᚹᛉ᛬ᚹᚷ᛬ᚨᚲ᛬ᚢᚢ᛬ᚦᚲ᛫ᚲᚦ᛬ᛊᚾ᛬ᚾᛃ᛬ᚺᚦ᛬ᚹᚹ᛬ᚹᚹ᛫ᚹᚷ᛬ᚹᛁ᛬ᚹᚲ᛬ᚹᛁ᛬ᚹᛇ᛬ᚹᛉ᛫ᚷᛊ᛬ᚹᚱ᛫ᚹᛇ᛬ᚹᛉ᛬ᚷᛊ᛫ᚹᚷ᛬ᚷᚦ᛫ᚹᚨ᛬ᚹᛁ᛬ᚹᚲ᛬ᚹᛊ᛬ᚷᚺ᛫ᚹᚱ᛬ᚹᚲ᛫ᚷᛊ᛬ᚹᚨ᛬ᚹᛉ᛬ᚹᚷ᛬ᚨᚲ᛫ᚲᛉ᛬ᚷᛈ᛬ᚹᛉ᛬ᚹᚲ᛫ᚹᚦ᛬ᚹᛈ᛫ᚹᚦ᛬ᚷᛊ᛫ᚹᚺ᛬ᚹᚱ᛬ᚷᚺ᛬ᚷᛊ᛬ᚷᚺ᛫ᚹᚷ᛬ᚹᛉ᛫ᚹᚷ᛬ᚷᚦ᛫ᚹᚹ᛬ᚹᚦ᛬ᚹᛈ᛬ᚹᛉ᛬ᚨᚲ᛫ᚲᚦ᛬ᚹᚲ᛫ᚷᛊ᛬ᚹᚨ᛬ᚹᛉ᛫ᚹᛉ᛬ᚹᚲ᛬ᚹᛊ᛬ᚨᚹ᛫ᚲᚦ᛬ᛊᚾ᛬ᚾᛃ᛬ᚺᚦ᛬ᚹᚷ᛫ᚹᛁ᛬ᚹᚹ᛬ᚷᚾ᛬ᚹᛉ᛬ᚹᛁ᛬ᚹᛊ᛬ᚷᚦ᛫ᚹᛊ᛬ᚹᛉ᛬ᚹᛁ᛬ᚹᛊ᛬ᚨᚲ᛬ᚨᚲ᛬ᚨᚲ᛫ᚲᛁ᛬ᚹᚲ᛬ᚹᛊ᛫ᚹᚦ᛬ᚷᛊ᛬ᛊᚾ᛬ᚾᛃ᛬ᚺᚦ᛬ᚷᚺ᛫ᚹᚲ᛬ᚹᚱ᛬ᚷᛊ᛫ᚹᚹ᛬ᚹᚦ᛬ᚹᚠ᛬ᚹᛉ᛫ᚹᚦ᛬ᚷᛊ᛫ᚷᛇ᛬ᚹᚱ᛬ᚷᛉ᛬ᚹᚹ᛬ᚹᛊ᛫ᚹᚺ᛬ᚹᚨ᛬ᚹᛁ᛬ᚹᚲ᛬ᚹᛇ᛬ᚹᛉ᛫ᚹᚷ᛬ᚷᛉ᛬ᚹᚺ᛬ᚹᚨ᛫ᚹᛁ᛬ᚹᚲ᛬ᚷᚦ᛬ᚷᛇ᛬ᚹᛁ᛬ᚷᚦ᛬ᚨᚲ᛬ᚨᚲ᛬ᚨᚲ᛫ᚲᚾ᛬ᚷᛉ᛬ᚷᛊ᛬ᚨᚲ᛬ᚨᚲ᛬ᚨᚲ᛬ᚢᚢ᛬ᚢᚢ᛬ᚦᚲ᛫ᚦᛃ᛬ᚦᛉ᛬ᚨᚱ᛬ᚦᚾ᛬ᚦᚾ᛬ᚨᚱ᛬ᚦᚾ᛬ᚦᛃ᛬ᚦᚾ᛬ᚦᛁ᛫ᚱᚠ᛬ᚷᚾ᛬ᚹᛉ᛬ᚷᚺ᛬ᚷᛊ᛬ᚹᚱ᛬ᚷᚾ᛬ᚹᛉ᛬ᚹᛊ᛫ᚷᚺ᛬ᚹᛉ᛬ᚷᚺ᛬ᚷᚺ᛬ᚹᚦ᛬ᚹᚱ᛬ᚹᚲ᛬ᚱᚷ᛬ᚢᚢ᛬ᚦᚲ᛫ᚲᚦ᛬ᚷᛊ᛬ᛊᚾ᛬ᚾᛃ᛬ᚺᚦ᛬ᚷᚺ᛫ᚹᚾ᛬ᚹᛉ᛬ᚹᛉ᛬ᚹᚲ᛫ᚹᛁ᛬ᚹᚹ᛬ᚹᚷ᛬ᚹᚱ᛬ᚷᚺ᛬ᚷᛊ᛫ᚦᚺ᛫ᚷᚦ᛬ᚹᛉ᛬ᚹᛁ᛬ᚷᚾ᛬ᚷᚺ᛬ᚨᚲ᛬ᚨᚲ᛫ᚱᚺ᛬ᚹᚨ᛬ᚹᛉ᛬ᛊᚾ᛬ᚾᛃ᛬ᚺᚦ᛬ᚷᚺ᛫ᚹᛇ᛬ᚹᚱ᛬ᚹᚦ᛬ᚹᚲ᛬ᚹᛇ᛫ᚷᛊ᛬ᚹᚱ᛫ᚷᚺ᛬ᚹᚲ᛬ᚹᛁ᛬ᚷᛃ᛬ᚨᚲ᛬ᚨᚲ᛬ᚨᚲ᛫ᚱᛇ᛬ᚹᚨ᛬ᚹᛁ᛬ᚷᛊ᛫ᚷᛇ᛬ᚹᚦ᛬ᚹᚹ᛬ᚹᚹ᛫ᚹᚾ᛬ᚹᛉ᛬ᚹᚺ᛬ᚹᚱ᛬ᚹᚷ᛬ᚹᛉ᛫ᚹᚱ᛬ᚹᛈ᛫ᚷᛊ᛬ᚹᚨ᛬ᚹᛉ᛫ᚷᚺ᛬ᚹᚺ᛬ᚹᛉ᛬ᚹᚲ᛬ᚹᛉ᛫ᚷᛇ᛬ᚹᚦ᛬ᚷᛊ᛬ᚹᚨ᛬ᚹᚱ᛬ᚷᛉ᛬ᚷᛊ᛫ᚹᚨ᛬ᚹᛉ᛬ᚷᚾ᛬ᚨᚲ᛬ᚨᚲ᛬ᚨᚲ᛫ᚲᚦ᛬ᚹᛈ᛫ᚷᚺ᛬ᚹᚨ᛬ᚹᛉ᛫ᚹᚹ᛬ᚹᛉ᛬ᚹᛁ᛬ᚷᛈ᛬ᚹᛉ᛬ᚷᚺ᛬ᚨᚹ᛫ᚲᚦ᛫ᚹᚹ᛬ᚹᛉ᛬ᚹᛁ᛬ᚷᛈ᛬ᚹᛉ᛬ᚨᚲ᛫ᚱᛇ᛬ᚹᛉ᛬ᛊᚾ᛬ᚾᛃ᛬ᚺᚦ᛬ᚷᚾ᛬ᚹᛉ᛫ᚷᚾ᛬ᚹᛉ᛬ᚹᛁ᛬ᚹᚺ᛬ᚹᚨ᛬ᚹᚦ᛬ᚹᚲ᛬ᚹᛇ᛫ᚹᛁ᛫ᚹᚹ᛬ᚹᛉ᛬ᚷᛈ᛬ᚹᛉ᛬ᚹᚹ᛫ᚹᚱ᛬ᚹᛈ᛫ᚷᚾ᛬ᚹᚦ᛬ᚷᚺ᛬ᚹᚠ᛫ᚷᛊ᛬ᚹᚨ᛬ᚹᛁ᛬ᚷᛊ᛬ᚨᛇ᛬ᚷᚺ᛫ᚹᚢ᛬ᚷᛉ᛬ᚷᚺ᛬ᚷᛊ᛫ᚷᛊ᛬ᚹᚱ᛬ᚹᚱ᛫ᚹᚨ᛬ᚹᚦ᛬ᚹᛇ᛬ᚹᚨ᛬ᚨᚲ᛫ᚲᛉ᛬ᚷᛈ᛬ᚹᛉ᛬ᚹᚲ᛫ᚹᚦ᛬ᚹᛈ᛫ᚷᛊ᛬ᚹᚨ᛬ᚹᛉ᛫ᚹᚺ᛬ᚹᚱ᛬ᚹᚲ᛬ᚹᚲ᛬ᚹᛉ᛬ᚹᚺ᛬ᚷᛊ᛬ᚹᚦ᛬ᚹᚱ᛬ᚹᚲ᛫ᚷᚾ᛬ᚹᛉ᛬ᚹᚷ᛬ᚹᛁ᛬ᚹᚦ᛬ᚹᚲ᛬ᚷᚺ᛫ᚹᛉ᛬ᚹᚲ᛬ᚹᚺ᛬ᚷᚾ᛬ᚷᚦ᛬ᚷᛃ᛬ᚷᛊ᛬ᚹᛉ᛬ᚹᛊ᛬ᚨᚹ᛫ᚷᛊ᛬ᚹᚨ᛬ᚹᛉ᛬ᚷᚦ᛫ᚹᚺ᛬ᚹᛁ᛬ᚹᚲ᛫ᚷᛊ᛬ᚷᚾ᛬ᚹᛁ᛬ᚹᚺ᛬ᚹᛉ᛫ᚹᚦ᛬ᚷᛊ᛫ᚹᚾ᛬ᚹᛁ᛬ᚹᚺ᛬ᚹᚠ᛫ᚷᛊ᛬ᚹᚱ᛫ᚹᚷ᛬ᚹᛉ᛬ᚨᚲ᛬ᚢᚢ᛬ᚢᚢ᛬ᚦᚲ᛫ᚦᛃ᛬ᚦᚦ᛬ᚨᚱ᛬ᚦᚾ᛬ᚦᚾ᛬ᚨᚱ᛬ᚦᚾ᛬ᚦᛃ᛬ᚦᚾ᛬ᚦᚾ᛫ᚱᚠ᛬ᚷᚾ᛬ᚹᛉ᛬ᚷᚺ᛬ᚷᛊ᛬ᚹᚱ᛬ᚷᚾ᛬ᚹᛉ᛬ᚹᛊ᛫ᚷᚺ᛬ᚹᛉ᛬ᚷᚺ᛬ᚷᚺ᛬ᚹᚦ᛬ᚹᚱ᛬ᚹᚲ᛬ᚱᚷ᛬ᚢᚢ᛬ᚦᚲ᛫ᚲᚦ᛬ᛊᚾ᛬ᚾᛃ᛬ᚺᚦ᛬ᚹᚷ᛫ᚷᚺ᛬ᚷᛊ᛬ᚹᚱ᛬ᚷᛃ᛬ᚷᛃ᛬ᚹᚦ᛬ᚹᚲ᛬ᚹᛇ᛫ᚹᛉ᛬ᚷᛈ᛬ᚹᛉ᛬ᚷᚾ᛬ᚷᚦ᛬ᚷᛊ᛬ᚹᚨ᛬ᚹᚦ᛬ᚹᚲ᛬ᚹᛇ᛬ᚨᚲ᛬ᚨᚲ᛫ᚱᚦ᛬ᚹᚱ᛬ᚷᛉ᛫ᚹᚺ᛬ᚹᛁ᛬ᚹᚲ᛫ᚹᚹ᛬ᚹᚱ᛬ᚹᚱ᛬ᚹᚠ᛫ᚹᛁ᛬ᚷᚺ᛫ᚹᚷ᛬ᚷᛉ᛬ᚹᚺ᛬ᚹᚨ᛫ᚹᛁ᛬ᚷᚺ᛫ᚷᚦ᛬ᚹᚱ᛬ᚷᛉ᛫ᚷᛇ᛬ᚹᛁ᛬ᚹᚲ᛬ᚷᛊ᛬ᚨᚹ᛫ᚷᚦ᛬ᚹᚱ᛬ᚷᛉ᛫ᚷᛇ᛬ᚹᚱ᛬ᚹᚲ᛬ᛊᚾ᛬ᚾᛃ᛬ᚺᚦ᛬ᚷᛊ᛫ᚹᛈ᛬ᚹᚦ᛬ᚹᚲ᛬ᚹᛊ᛫ᚹᛁ᛬ᚹᚲ᛬ᚷᚦ᛬ᚷᛊ᛬ᚹᚨ᛬ᚹᚦ᛬ᚹᚲ᛬ᚹᛇ᛬ᚦᚠ᛫ᚹᛉ᛬ᚷᛈ᛬ᚹᛉ᛬ᚹᚲ᛫ᚹᚦ᛬ᚹᛈ᛫ᚷᛊ᛬ᚹᚨ᛬ᚹᚦ᛬ᚷᚺ᛫ᚷᚺ᛬ᚹᚦ᛬ᚷᛊ᛬ᚹᛉ᛫ᚹᚨ᛬ᚹᛁ᛬ᚷᚺ᛫ᚹᛁ᛫ᚷᛃ᛬ᚷᛉ᛬ᚹᚾ᛬ᚹᚹ᛬ᚹᚦ᛬ᚹᚺ᛫ᚷᚾ᛬ᚹᛉ᛬ᚷᛃ᛬ᚹᚱ᛬ᚨᚹ᛫ᚲᚦ᛬ᛊᚾ᛬ᚾᛃ᛬ᚺᚦ᛬ᚷᛈ᛬ᚹᛉ᛫ᚹᛉ᛬ᚹᚲ᛬ᚹᚺ᛬ᚷᚾ᛬ᚷᚦ᛬ᚷᛃ᛬ᚷᛊ᛬ᚹᛉ᛬ᚹᛊ᛫ᚷᛊ᛬ᚹᚨ᛬ᚹᛉ᛫ᚹᛈ᛬ᚹᚦ᛬ᚹᚹ᛬ᚹᛉ᛬ᚨᚲ᛬ᚨᚲ᛬ᚨᚲ᛫ᚲᚦ᛬ᛊᚾ᛬ᚾᛃ᛬ᚺᚦ᛬ᚹᚷ᛫ᚷᛊ᛬ᚹᛁ᛬ᚹᚠ᛬ᚹᚦ᛬ᚹᚲ᛬ᚹᛇ᛫ᚷᛊ᛬ᚹᚨ᛬ᚹᚦ᛬ᚷᚺ᛫ᚷᚺ᛬ᚹᛉ᛬ᚹᚺ᛬ᚷᚾ᛬ᚹᛉ᛬ᚷᛊ᛫ᚷᛇ᛬ᚹᚦ᛬ᚷᛊ᛬ᚹᚨ᛫ᚹᚷ᛬ᚹᛉ᛬ᚨᚲ᛬ᚨᚲ᛬ᚨᚲ᛬ᚢᚢ᛬ᚢᚢ᛬ᚦᚲ᛫ᚦᛃ᛬ᚦᚾ᛬ᚨᚱ᛬ᚦᚾ᛬ᚦᛇ᛬ᚨᚱ᛬ᚦᚾ᛬ᚦᛃ᛬ᚦᚾ᛬ᚦᛈ᛫ᚱᚠ᛬ᚷᚾ᛬ᚹᛉ᛬ᚷᚺ᛬ᚷᛊ᛬ᚹᚱ᛬ᚷᚾ᛬ᚹᛉ᛬ᚹᛊ᛫ᚷᚺ᛬ᚹᛉ᛬ᚷᚺ᛬ᚷᚺ᛬ᚹᚦ᛬ᚹᚱ᛬ᚹᚲ᛬ᚱᚷ᛬ᚢᚢ᛬ᚦᚲ᛫ᚲᛁ᛬ᚷᚾ᛬ᚹᛉ᛫ᚷᚦ᛬ᚹᚱ᛬ᚷᛉ᛫ᚷᚺ᛬ᚷᛊ᛬ᚹᚦ᛬ᚹᚹ᛬ᚹᚹ᛫ᚹᛁ᛬ᚹᚹ᛬ᚹᚦ᛬ᚷᛈ᛬ᚹᛉ᛫ᚦᚱ᛬ᚨᚲ᛬ᚨᚲ᛬ᚦᚱ᛬ᚨᚲ᛬ᚨᚲ᛬ᚨᚲ᛬ᚦᚱ᛬ᚨᚲ᛬ᚨᚲ᛬ᚨᚲ᛫ᚨᚲ᛬ᚨᚲ᛫ᚨᚲ᛬ᚢᚢ᛬ᚦᚲ᛫ᚲᛁ᛬ᚷᛇ᛬ᚹᛁ᛬ᚹᚦ᛬ᚷᛊ᛬ᚹᚦ᛬ᚹᚲ᛬ᚹᛇ᛫ᚹᚺ᛬ᚹᚱ᛬ᚹᚷ᛬ᚹᚷ᛬ᚹᛁ᛬ᚹᚲ᛬ᚹᛊ᛬ᚷᚺ᛬ᚨᚲ᛬ᚨᚲ᛬ᚨᚲ᛬ᚢᚢ᛬ᚦᚲ᛫ᚱᚱ"
       )
     )
     |> assign(:warez_glitching, MapSet.new())}
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
    all_positions = for x <- 0..(size - 1), y <- 0..(size - 1), do: {x, y}
    mine_positions = Enum.take_random(all_positions, mine_count) |> MapSet.new()

    # Create board with mine counts
    for x <- 0..(size - 1), y <- 0..(size - 1), into: %{} do
      is_mine = MapSet.member?(mine_positions, {x, y})

      adjacent_mines =
        if is_mine do
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
  def handle_event("toggle_start_menu", _, socket) do
    {:noreply, assign(socket, :start_menu_open, not socket.assigns.start_menu_open)}
  end

  def handle_event("close_start_menu", _, socket) do
    {:noreply, assign(socket, :start_menu_open, false)}
  end

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

    socket =
      socket
      |> assign(:windows, windows)
      |> assign(:active_window, window_id)
      |> assign(:start_menu_open, false)
      |> assign(:z_index_counter, socket.assigns.z_index_counter + 1)

    socket =
      if app == "warez" do
        assign(socket, :warez_glitching, MapSet.put(socket.assigns.warez_glitching, window_id))
      else
        socket
      end

    {:noreply, socket}
  end

  def handle_event("close_window", %{"window-id" => window_id}, socket) do
    windows = Map.delete(socket.assigns.windows, window_id)

    active =
      if socket.assigns.active_window == window_id, do: nil, else: socket.assigns.active_window

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

  # Warez glitch done
  def handle_event("warez_glitch_done", %{"window-id" => window_id}, socket) do
    {:noreply,
     assign(socket, :warez_glitching, MapSet.delete(socket.assigns.warez_glitching, window_id))}
  end

  # Warez content change
  def handle_event("warez_change", %{"content" => content}, socket) do
    {:noreply, assign(socket, :warez_content, content)}
  end

  # Notepad events
  def handle_event("notepad_change", %{"content" => content}, socket) do
    {:noreply, assign(socket, :notepad_content, content)}
  end

  # Snake events
  def handle_event("snake_start", _, socket) do
    snake_game =
      if socket.assigns.snake_game.game_over do
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

    new_head =
      case game.direction do
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
    valid_change =
      case {snake_game.direction, new_direction} do
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
        {:noreply,
         assign(socket, :minesweeper_game, %{game | flagged: MapSet.delete(game.flagged, {x, y})})}

      true ->
        {:noreply,
         assign(socket, :minesweeper_game, %{game | flagged: MapSet.put(game.flagged, {x, y})})}
    end
  end

  def handle_event("minesweeper_reset", _, socket) do
    {:noreply, assign(socket, :minesweeper_game, init_minesweeper_game())}
  end

  # Calculator events
  def handle_event("calc_digit", %{"digit" => digit}, socket) do
    display =
      if socket.assigns.calculator_new_number do
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

    result =
      if socket.assigns.calculator_memory && socket.assigns.calculator_operation do
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

      result =
        calculate(socket.assigns.calculator_memory, current, socket.assigns.calculator_operation)

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

    display =
      if socket.assigns.calculator_new_number do
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
    windows =
      update_in(socket.assigns.windows, [window_id, :z_index], fn _ ->
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
      "warez" -> "Warez"
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
      "warez" -> 520
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
      "warez" -> 420
      "terminal" -> 400
      _ -> 300
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div
      id={@id}
      class="os-container relative w-full h-[700px] bg-gradient-to-br from-gray-900 via-purple-950/50 to-gray-900 rounded-2xl border border-purple-500/30 overflow-hidden"
    >
      <!-- Background Image -->
      <div class="absolute inset-0 flex items-center justify-center pointer-events-none opacity-20">
        <img src="/images/shdxwOS.png" alt="" class="max-w-md max-h-96 object-contain" />
      </div>
      
    <!-- Click overlay to close start menu -->
      <%= if @start_menu_open do %>
        <div
          class="absolute inset-0 z-40"
          phx-click="close_start_menu"
          phx-target={@myself}
        >
        </div>
      <% end %>
      
    <!-- Desktop -->
      <div class="desktop absolute inset-0 p-6 pb-16" phx-hook="ShdxwOS" id={"#{@id}-desktop"}>
        <!-- Desktop Icons -->
        <div class="grid grid-cols-6 gap-4">
          <.desktop_icon icon="notepad" label="Notepad" target={@myself} />
          <.desktop_icon icon="snake" label="Snake" target={@myself} />
          <.desktop_icon icon="minesweeper" label="Démineur" target={@myself} />
          <.desktop_icon icon="calculator" label="Calculatrice" target={@myself} />
          <.desktop_icon icon="warez" label="Warez" target={@myself} />
        </div>
        
    <!-- Windows -->
        <%= for {window_id, window} <- @windows do %>
          <.window
            window={window}
            myself={@myself}
            component_id={@id}
            active={@active_window == window_id}
            notepad_content={@notepad_content}
            snake_game={@snake_game}
            minesweeper_game={@minesweeper_game}
            calculator_display={@calculator_display}
            warez_content={@warez_content}
            warez_glitching={MapSet.member?(@warez_glitching, window_id)}
          />
        <% end %>
      </div>
      
    <!-- Start Menu (Windows XP Style) -->
      <.start_menu :if={@start_menu_open} myself={@myself} />
      
    <!-- Taskbar -->
      <div class="taskbar absolute bottom-0 left-0 right-0 h-14 bg-black/80 backdrop-blur-xl border-t border-purple-500/30 flex items-center px-4 gap-2 z-50">
        <!-- Start Button -->
        <button
          phx-click="toggle_start_menu"
          phx-target={@myself}
          class={"start-btn flex items-center gap-2 px-4 py-2 rounded-lg cursor-pointer transition-all #{if @start_menu_open, do: "bg-purple-600/70 shadow-lg shadow-purple-600/30", else: "bg-purple-600/30 hover:bg-purple-600/50"}"}
        >
          <div class="w-6 h-6 bg-gradient-to-br from-purple-500 to-violet-600 rounded-md flex items-center justify-center">
            <span class="text-white text-xs font-black">S</span>
          </div>
          <span class="text-white font-semibold text-sm">Menu</span>
        </button>

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
              {window.title}
            </button>
          <% end %>
        </div>
        
    <!-- Clock -->
        <div class="text-white/60 text-sm font-mono">
          {Calendar.strftime(DateTime.utc_now(), "%H:%M")}
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
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
              />
            </svg>
          <% "snake" -> %>
            <svg class="w-8 h-8 text-white" fill="currentColor" viewBox="0 0 24 24">
              <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z" />
            </svg>
          <% "minesweeper" -> %>
            <svg class="w-8 h-8 text-white" fill="currentColor" viewBox="0 0 24 24">
              <circle cx="12" cy="12" r="10" fill="none" stroke="currentColor" stroke-width="2" />
              <circle cx="12" cy="12" r="3" />
              <line x1="12" y1="2" x2="12" y2="6" stroke="currentColor" stroke-width="2" />
              <line x1="12" y1="18" x2="12" y2="22" stroke="currentColor" stroke-width="2" />
              <line x1="2" y1="12" x2="6" y2="12" stroke="currentColor" stroke-width="2" />
              <line x1="18" y1="12" x2="22" y2="12" stroke="currentColor" stroke-width="2" />
            </svg>
          <% "calculator" -> %>
            <svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 14h.01M12 14h.01M15 11h.01M12 11h.01M9 11h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z"
              />
            </svg>
          <% "warez" -> %>
            <img src="/images/1299051.svg" alt="Warez" class="w-8 h-8 invert" />
          <% _ -> %>
            <div class="w-8 h-8 bg-white/20 rounded"></div>
        <% end %>
      </div>
      <span class="text-white text-xs font-medium drop-shadow-lg">{@label}</span>
    </button>
    """
  end

  defp start_menu(assigns) do
    ~H"""
    <div class="start-menu absolute bottom-14 left-4 w-96 bg-gradient-to-b from-gray-900 to-gray-950 rounded-t-xl border border-purple-500/30 shadow-2xl shadow-purple-900/50 z-50 overflow-hidden">
      <!-- Header with user profile (Windows XP style) -->
      <div class="bg-gradient-to-r from-purple-700 via-purple-600 to-violet-700 p-4 flex items-center gap-4">
        <div class="w-16 h-16 rounded-lg bg-gradient-to-br from-gray-800 to-gray-900 border-2 border-white/30 shadow-lg overflow-hidden flex items-center justify-center">
          <span class="text-3xl font-black text-transparent bg-clip-text bg-gradient-to-br from-purple-400 to-violet-400">
            S
          </span>
        </div>
        <div>
          <p class="text-white font-bold text-lg">SHDXW</p>
          <p class="text-white/70 text-sm">Developer / ṯ̵̺͆r̶͚̈́ǎ̸͙̤͐c̸͙͊͝k̶͖̊͌e̴̼̙̊r̴̖̚</p>
        </div>
      </div>
      
    <!-- Main content area (two columns like XP) -->
      <div class="flex">
        <!-- Left column - Pinned & Recent apps -->
        <div class="flex-1 border-r border-white/10 bg-white/5">
          <div class="p-2">
            <p class="text-white/40 text-xs px-2 py-1 uppercase tracking-wider">Applications</p>

            <.start_menu_item
              icon="notepad"
              label="Notepad"
              description="Éditeur de texte"
              app="notepad"
              myself={@myself}
            />
            <.start_menu_item
              icon="snake"
              label="Snake"
              description="Jeu classique"
              app="snake"
              myself={@myself}
            />
            <.start_menu_item
              icon="minesweeper"
              label="Démineur"
              description="Jeu de réflexion"
              app="minesweeper"
              myself={@myself}
            />
            <.start_menu_item
              icon="calculator"
              label="Calculatrice"
              description="Calculs simples"
              app="calculator"
              myself={@myself}
            />
            <.start_menu_item
              icon="warez"
              label="Warez"
              description="Terminal crypté"
              app="warez"
              myself={@myself}
            />
          </div>

          <div class="border-t border-white/10 p-2">
            <p class="text-white/40 text-xs px-2 py-1 uppercase tracking-wider">
              Tous les programmes
            </p>
            <div class="px-2 py-2 text-white/50 text-sm flex items-center gap-2 hover:bg-white/10 rounded cursor-pointer">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M9 5l7 7-7 7"
                />
              </svg>
              Plus d'applications...
            </div>
          </div>
        </div>
        
    <!-- Right column - System shortcuts -->
        <div class="w-36 bg-gradient-to-b from-purple-950/50 to-gray-950 p-2">
          <.start_menu_shortcut icon="folder" label="Mes Documents" />
          <.start_menu_shortcut icon="image" label="Mes Images" />
          <.start_menu_shortcut icon="music" label="Ma Musique" />
          <.start_menu_shortcut icon="computer" label="Poste de travail" />

          <div class="my-2 border-t border-white/10"></div>

          <.start_menu_shortcut icon="settings" label="Paramètres" />
          <.start_menu_shortcut icon="help" label="Aide" />
        </div>
      </div>
      
    <!-- Footer with shutdown button (Windows XP style) -->
      <div class="bg-gradient-to-r from-purple-900/50 to-violet-900/50 border-t border-purple-500/30 p-2 flex justify-end gap-2">
        <button class="flex items-center gap-2 px-3 py-1.5 text-white/70 hover:text-white hover:bg-white/10 rounded transition-all text-sm">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"
            />
          </svg>
          Verrouiller
        </button>
        <button class="flex items-center gap-2 px-3 py-1.5 bg-red-600/80 hover:bg-red-600 text-white rounded transition-all text-sm">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M18.364 18.364A9 9 0 005.636 5.636m12.728 12.728A9 9 0 015.636 5.636m12.728 12.728L5.636 5.636"
            />
          </svg>
          Éteindre
        </button>
      </div>
    </div>
    """
  end

  attr :icon, :string, required: true
  attr :label, :string, required: true
  attr :description, :string, required: true
  attr :app, :string, required: true
  attr :myself, :any, required: true

  defp start_menu_item(assigns) do
    ~H"""
    <button
      phx-click="open_app"
      phx-value-app={@app}
      phx-target={@myself}
      class="w-full flex items-center gap-3 px-2 py-2 hover:bg-purple-600/30 rounded-lg transition-all group"
    >
      <div class="w-10 h-10 bg-gradient-to-br from-purple-600/50 to-violet-600/50 rounded-lg flex items-center justify-center border border-purple-500/30 group-hover:border-purple-500/60">
        <.menu_icon icon={@icon} />
      </div>
      <div class="text-left">
        <p class="text-white text-sm font-medium">{@label}</p>
        <p class="text-white/50 text-xs">{@description}</p>
      </div>
    </button>
    """
  end

  attr :icon, :string, required: true
  attr :label, :string, required: true

  defp start_menu_shortcut(assigns) do
    ~H"""
    <button class="w-full flex items-center gap-2 px-2 py-1.5 hover:bg-white/10 rounded transition-all text-left">
      <.shortcut_icon icon={@icon} />
      <span class="text-white/70 text-xs">{@label}</span>
    </button>
    """
  end

  defp menu_icon(assigns) do
    ~H"""
    <%= case @icon do %>
      <% "notepad" -> %>
        <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
          />
        </svg>
      <% "snake" -> %>
        <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z"
          />
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
          />
        </svg>
      <% "minesweeper" -> %>
        <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"
          />
        </svg>
      <% "calculator" -> %>
        <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 14h.01M12 14h.01M15 11h.01M12 11h.01M9 11h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z"
          />
        </svg>
      <% "warez" -> %>
        <img src="/images/1299051.svg" alt="Warez" class="w-6 h-6 invert" />
      <% _ -> %>
        <div class="w-6 h-6 bg-white/20 rounded"></div>
    <% end %>
    """
  end

  defp shortcut_icon(assigns) do
    ~H"""
    <%= case @icon do %>
      <% "folder" -> %>
        <svg class="w-4 h-4 text-yellow-500" fill="currentColor" viewBox="0 0 24 24">
          <path d="M10 4H4c-1.1 0-1.99.9-1.99 2L2 18c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V8c0-1.1-.9-2-2-2h-8l-2-2z" />
        </svg>
      <% "image" -> %>
        <svg class="w-4 h-4 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"
          />
        </svg>
      <% "music" -> %>
        <svg class="w-4 h-4 text-purple-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M9 19V6l12-3v13M9 19c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zm12-3c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zM9 10l12-3"
          />
        </svg>
      <% "computer" -> %>
        <svg class="w-4 h-4 text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"
          />
        </svg>
      <% "settings" -> %>
        <svg class="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"
          />
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"
          />
        </svg>
      <% "help" -> %>
        <svg class="w-4 h-4 text-blue-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M8.228 9c.549-1.165 2.03-2 3.772-2 2.21 0 4 1.343 4 3 0 1.4-1.278 2.575-3.006 2.907-.542.104-.994.54-.994 1.093m0 3h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
          />
        </svg>
      <% _ -> %>
        <div class="w-4 h-4 bg-white/20 rounded"></div>
    <% end %>
    """
  end

  defp window(assigns) do
    ~H"""
    <div
      id={@window.id}
      class={"window absolute bg-gray-900/95 backdrop-blur-xl rounded-xl border shadow-2xl overflow-hidden transition-opacity #{if @window.minimized, do: "opacity-0 pointer-events-none", else: "opacity-100"} #{if @active, do: "border-purple-500/50", else: "border-white/20"}"}
      style={"left: #{@window.x}px; top: #{@window.y}px; width: #{@window.width}px; height: #{@window.height}px; z-index: #{@window.z_index};"}
      phx-hook="Draggable"
      data-component-id={@component_id}
    >
      <!-- Title Bar -->
      <div
        class="window-titlebar h-10 bg-black/50 flex items-center justify-between px-4 cursor-move select-none"
        data-window-id={@window.id}
      >
        <span class="text-white text-sm font-medium pointer-events-none">{@window.title}</span>
        <div class="flex gap-2">
          <button
            phx-click="minimize_window"
            phx-value-window-id={@window.id}
            phx-target={@myself}
            class="w-4 h-4 rounded-full bg-yellow-500 hover:bg-yellow-400 transition-colors"
          >
          </button>
          <button
            phx-click="close_window"
            phx-value-window-id={@window.id}
            phx-target={@myself}
            class="w-4 h-4 rounded-full bg-red-500 hover:bg-red-400 transition-colors"
          >
          </button>
        </div>
      </div>
      
    <!-- Content -->
      <div
        class="window-content h-[calc(100%-2.5rem)] overflow-auto"
        phx-mousedown="focus_window"
        phx-value-window-id={@window.id}
        phx-target={@myself}
      >
        <%= case @window.app do %>
          <% "notepad" -> %>
            <.notepad_app content={@notepad_content} myself={@myself} />
          <% "snake" -> %>
            <.snake_app game={@snake_game} myself={@myself} />
          <% "minesweeper" -> %>
            <.minesweeper_app game={@minesweeper_game} myself={@myself} />
          <% "calculator" -> %>
            <.calculator_app display={@calculator_display} myself={@myself} />
          <% "warez" -> %>
            <.warez_app
              content={@warez_content}
              myself={@myself}
              glitching={@warez_glitching}
              window_id={@window.id}
              component_id={@component_id}
            />
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
        <span class="text-white font-bold">Score: {@game.score}</span>
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
          >
          </div>
        <% end %>

        <div
          class="absolute bg-red-500 rounded-full animate-pulse"
          style={"left: #{elem(@game.food, 0) * 20 + 2}px; top: #{elem(@game.food, 1) * 20 + 2}px; width: 14px; height: 14px;"}
        >
        </div>
      </div>

      <div class="mt-4 flex gap-2">
        <%= if not @game.running do %>
          <button
            phx-click="snake_start"
            phx-target={@myself}
            class="px-4 py-2 bg-purple-600 hover:bg-purple-700 text-white rounded-lg font-medium transition-colors"
          >
            {if @game.game_over, do: "Rejouer", else: "Démarrer"}
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
        <span class="text-white font-bold">Mines: {@game.mines - MapSet.size(@game.flagged)}</span>
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
                    <span class={"#{get_number_color(cell.adjacent)}"}>{cell.adjacent}</span>
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
    event_value =
      case assigns.click do
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
      {render_slot(@inner_block)}
    </button>
    """
  end

  defp calculator_app(assigns) do
    ~H"""
    <div class="h-full flex flex-col p-4 bg-gray-950">
      <!-- Display -->
      <div class="bg-gray-800 rounded-lg p-4 mb-4">
        <div class="text-right text-white text-3xl font-mono overflow-hidden">
          {@display}
        </div>
      </div>
      
    <!-- Buttons -->
      <div class="grid grid-cols-4 gap-2 flex-1">
        <.calc_btn click="calc_clear" myself={@myself} class="bg-red-600 hover:bg-red-700 col-span-2">
          AC
        </.calc_btn>
        <.calc_btn
          click="calc_operation"
          value="/"
          myself={@myself}
          class="bg-purple-600 hover:bg-purple-700"
        >
          ÷
        </.calc_btn>
        <.calc_btn
          click="calc_operation"
          value="*"
          myself={@myself}
          class="bg-purple-600 hover:bg-purple-700"
        >
          ×
        </.calc_btn>

        <.calc_btn click="calc_digit" value="7" myself={@myself}>7</.calc_btn>
        <.calc_btn click="calc_digit" value="8" myself={@myself}>8</.calc_btn>
        <.calc_btn click="calc_digit" value="9" myself={@myself}>9</.calc_btn>
        <.calc_btn
          click="calc_operation"
          value="-"
          myself={@myself}
          class="bg-purple-600 hover:bg-purple-700"
        >
          −
        </.calc_btn>

        <.calc_btn click="calc_digit" value="4" myself={@myself}>4</.calc_btn>
        <.calc_btn click="calc_digit" value="5" myself={@myself}>5</.calc_btn>
        <.calc_btn click="calc_digit" value="6" myself={@myself}>6</.calc_btn>
        <.calc_btn
          click="calc_operation"
          value="+"
          myself={@myself}
          class="bg-purple-600 hover:bg-purple-700"
        >
          +
        </.calc_btn>

        <.calc_btn click="calc_digit" value="1" myself={@myself}>1</.calc_btn>
        <.calc_btn click="calc_digit" value="2" myself={@myself}>2</.calc_btn>
        <.calc_btn click="calc_digit" value="3" myself={@myself}>3</.calc_btn>
        <.calc_btn
          click="calc_equals"
          myself={@myself}
          class="bg-green-600 hover:bg-green-700 row-span-2"
        >
          =
        </.calc_btn>

        <.calc_btn click="calc_digit" value="0" myself={@myself} class="col-span-2">0</.calc_btn>
        <.calc_btn click="calc_decimal" myself={@myself}>.</.calc_btn>
      </div>
    </div>
    """
  end

  defp warez_app(assigns) do
    ~H"""
    <div class="h-full relative">
      <!-- Glitch overlay -->
      <%= if @glitching do %>
        <div
          id={"glitch-#{@window_id}"}
          phx-hook="WarezGlitch"
          data-component-id={@component_id}
          data-window-id={@window_id}
          class="absolute inset-0 z-10 bg-black overflow-hidden"
        >
          <style>
            @keyframes glitch-skew {
              0% { transform: skew(0deg); }
              10% { transform: skew(-2deg); }
              20% { transform: skew(4deg); }
              30% { transform: skew(-1deg); }
              40% { transform: skew(3deg); }
              50% { transform: skew(-3deg); }
              60% { transform: skew(2deg); }
              70% { transform: skew(-4deg); }
              80% { transform: skew(1deg); }
              90% { transform: skew(-2deg); }
              100% { transform: skew(0deg); }
            }
            @keyframes glitch-flicker {
              0%, 100% { opacity: 1; }
              5% { opacity: 0.3; }
              10% { opacity: 0.8; }
              15% { opacity: 0.1; }
              20% { opacity: 0.9; }
              30% { opacity: 0.5; }
              35% { opacity: 1; }
              50% { opacity: 0.2; }
              55% { opacity: 0.8; }
              70% { opacity: 0.4; }
              75% { opacity: 1; }
              85% { opacity: 0.6; }
              90% { opacity: 0.1; }
              95% { opacity: 0.9; }
            }
            @keyframes glitch-color {
              0% { text-shadow: 2px 0 #ff0000, -2px 0 #00ff00; }
              25% { text-shadow: -2px 0 #ff0000, 2px 0 #0000ff; }
              50% { text-shadow: 2px 2px #00ff00, -2px -2px #ff0000; }
              75% { text-shadow: -2px 0 #0000ff, 2px 0 #ff0000; }
              100% { text-shadow: 2px 0 #ff0000, -2px 0 #00ff00; }
            }
            @keyframes scanline {
              0% { top: -10%; }
              100% { top: 110%; }
            }
            .glitch-text {
              animation: glitch-skew 0.3s infinite, glitch-color 0.2s infinite, glitch-flicker 0.4s infinite;
              font-family: monospace;
            }
            .glitch-scanline {
              animation: scanline 0.8s linear infinite;
            }
          </style>

          <div class="glitch-text w-full h-full flex flex-col items-center justify-center text-green-500 text-sm p-4">
            <div class="mb-2 text-red-500 text-xs">ERROR 0xDEAD :: BUFFER OVERFLOW</div>
            <div class="text-purple-400">
              &#9608;&#9608;&#9608; INITIALIZING &#9608;&#9608;&#9608;
            </div>
            <div class="mt-1 text-green-400 text-xs">%$#@!&amp;*^~`&rbrace;&lbrace;][|</div>
            <div class="mt-1 text-red-400 text-xs">SEGFAULT AT 0x7FFF5FBFF8C0</div>
            <div class="mt-1 text-yellow-400 text-xs">kernel panic - not syncing</div>
            <div class="mt-2 text-purple-300 text-lg font-bold">S H D X W</div>
            <div class="mt-1 text-green-500 text-xs">
              &#9617;&#9618;&#9619;&#9608;&#9619;&#9618;&#9617;&#9608;&#9619;&#9618;&#9617;&#9608;&#9619;&#9618;&#9617;
            </div>
          </div>
          
    <!-- Scanline effect -->
          <div class="glitch-scanline absolute left-0 w-full h-1 bg-white/10 pointer-events-none">
          </div>
          <!-- Horizontal glitch bars -->
          <div class="absolute top-1/4 left-0 w-full h-1 bg-red-500/30 animate-pulse"></div>
          <div class="absolute top-2/3 left-0 w-full h-0.5 bg-green-500/20 animate-pulse"></div>
        </div>
      <% end %>
      
    <!-- Actual warez content (notepad-like) -->
      <div class={"h-full flex flex-col #{if @glitching, do: "invisible", else: ""}"}>
        <div class="bg-gray-800/50 px-3 py-1 text-xs text-green-500/60 border-b border-green-500/20 font-mono">
          [ENCRYPTED] | NODE: shdxw-relay-07 | PING: 12ms
        </div>
        <textarea
          phx-change="warez_change"
          phx-target={@myself}
          name="content"
          class="flex-1 w-full bg-black text-green-400/90 p-4 font-mono text-sm resize-none focus:outline-none caret-green-500"
          placeholder="> _"
        ><%= @content %></textarea>
      </div>
    </div>
    """
  end
end
