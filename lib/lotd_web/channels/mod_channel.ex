defmodule LotdWeb.ModChannel do
  use LotdWeb, :channel

  alias Phoenix.View
  alias Lotd.{Accounts, Gallery}

  def join("mod", _params, socket) do
    found_ids = if authenticated?(socket) do
      socket.assigns.user
      |> Accounts.get_user_character!(socket.assigns.user.active_character_id)
      |> Accounts.load_item_ids()
    else
      []
    end

    mods = if authenticated?(socket) do
      socket.assigns.user
      |> Accounts.get_user_character!(socket.assigns.user.active_character_id)
      |> Accounts.get_character_mods()
    else
      Gallery.list_mods()
    end

    {:ok, %{ mods: View.render_many(mods, DataView, "mod.json", found_ids: found_ids)}, socket}
  end
end
