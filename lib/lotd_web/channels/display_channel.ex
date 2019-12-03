defmodule LotdWeb.DisplayChannel do
  use LotdWeb, :channel

  alias Phoenix.View
  alias Lotd.{Accounts, Museum}

  def join("display", _params, socket) do
    found_ids = if authenticated?(socket) do
      socket.assigns.user
      |> Accounts.get_user_character!(socket.assigns.user.active_character_id)
      |> Accounts.load_display_ids()
    else
      []
    end

    mod_ids = if authenticated?(socket) do
      socket.assigns.user
      |> Accounts.get_user_character!(socket.assigns.user.active_character_id)
      |> Accounts.load_mod_ids()
    else
      Museum.list_mods()
    end

    displays = Museum.list_displays()
    |> View.render_many(DataView, "display.json", found_ids: found_ids, mod_ids: mod_ids)

    {:ok, %{ displays: displays}, socket}
  end
end
