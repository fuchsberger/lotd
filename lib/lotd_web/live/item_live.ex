defmodule LotdWeb.ItemLive do

  use LotdWeb, :live

  import Lotd.Repo, only: [list_options: 1]

  alias Lotd.{Accounts, Museum}
  alias Lotd.Museum.{Display, Mod}

  alias LotdWeb.ItemView

  def render(assigns), do: ItemView.render("index.html", assigns)

  def mount(session, socket) do

    mod_options = list_options(Mod)

    user = if session.user_id, do: Accounts.get_user!(session.user_id), else: nil
    character_item_ids = Enum.map(user.active_character.items, & &1.id)

    items = unless is_nil(user) do
      Museum.list_items()
      |> Enum.map(fn item ->
        Map.put(item, :collected, Enum.member?(character_item_ids, item.id)) end)
    else
      Museum.list_items()
    end
    |> Enum.map(fn i -> Map.put(i, :mod, mod_options[i.mod_id]) end)

    socket = assign socket,
      items: items,
      search: "",
      sort: "display",
      user: user

    {:ok, filter(socket)}
  end

  def handle_event("toggle_collected", %{"id" => id}, socket) do

    character = socket.assigns.user.active_character
    item = Enum.find(socket.assigns.items, & &1.id == String.to_integer(id))

    if item.collected,
      do: Accounts.update_character_remove_item(character, item.id),
      else: Accounts.update_character_collect_item(character, item)

    item = Map.put(item, :collected, !item.collected)

    {:noreply, update_item(socket, item)}
  end

  defp filter(socket) do
    filter = String.downcase(socket.assigns.search)
    visible_items = Enum.filter(socket.assigns.items,
      fn i -> String.contains?(String.downcase(i.name), filter) end)

    assign socket, visible_items: visible_items
  end

  defp update_item(socket, item) do
    index = Enum.find_index(socket.assigns.items, fn i -> i.id == item.id end)
    items = List.replace_at(socket.assigns.items, index, item)

    socket
    |> assign(:items, items)
    |> filter()
  end
end
