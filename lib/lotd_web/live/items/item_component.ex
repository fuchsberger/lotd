defmodule LotdWeb.ItemsLive.ItemComponent do
  use Phoenix.LiveComponent
  use Phoenix.HTML

  alias Lotd.Accounts

  def handle_event("toggle_found", _params, socket) do
    item = socket.assigns.item
    if item.found,
      do: Accounts.update_character_remove_item(socket.assigns.character, item.id),
      else: Accounts.update_character_add_item(socket.assigns.character, item)

    {:noreply, assign(socket, :item, Map.put(item, :found, !item.found))}
  end

  def render(assigns) do
    Phoenix.View.render(LotdWeb.ItemView, "item.html", assigns)
  end
end
