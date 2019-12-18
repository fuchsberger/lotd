defmodule LotdWeb.ItemLive do

  use LotdWeb, :live

  alias Lotd.{Accounts, Museum}
  alias LotdWeb.ItemView

  def render(assigns), do: ItemView.render("index.html", assigns)

  def mount(session, socket) do

    user = if session.user_id, do: Accounts.get_user!(session.user_id), else: nil

    socket = assign socket,
      items: sort(Museum.list_items(user), "displays"),
      search: "",
      sort: "displays",
      user: user

    {:ok, filter(socket)}
  end

  def handle_event("toggle_collected", %{"id" => id}, socket) do
    id = String.to_integer(id)
    character = socket.assigns.user.active_character
    item = Enum.find(socket.assigns.items, & &1.id == id)

    unless is_nil(Enum.find(character.items, fn i -> i.id == id end)),
      do: Accounts.update_character_remove_item(character, item.id),
      else: Accounts.update_character_collect_item(character, item)

    {:noreply, assign(socket, user: Accounts.get_user!(socket.assigns.user.id))}
  end

  def handle_info({:search, search_query}, socket) do
    socket = assign socket, search: search_query
    {:noreply, filter(socket)}
  end

  def handle_params(%{"sort_by" => sort_by}, _uri, socket) do
    case sort_by do
      sort_by when sort_by in ~w(name displays room) ->
        socket = assign socket,
          items: sort(socket.assigns.items, sort_by, sort_by == socket.assigns.sort),
          sort: sort_by
        {:noreply, filter(socket)}
      _ ->
        {:noreply, socket}
    end
  end

  def handle_params(_params, _uri, socket), do: {:noreply, socket}

  defp filter(socket) do
    filter = String.downcase(socket.assigns.search)
    visible_items = Enum.filter(socket.assigns.items,
      fn i -> String.contains?(String.downcase(i.name), filter) end)

    assign socket, visible_items: visible_items
  end
end
