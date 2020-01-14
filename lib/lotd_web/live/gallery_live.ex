defmodule LotdWeb.GalleryLive do

  use Phoenix.LiveView, container: {:div, class: "container h-100"}
  alias Lotd.{Accounts, Gallery}

  def render(assigns), do: LotdWeb.GalleryView.render("index.html", assigns)

  def mount(params, socket) do
    user_id = Map.get(params, "user_id")
    user = unless is_nil(user_id), do: Accounts.get_user!(user_id), else: nil

    {:ok, assign(socket,
      display: nil,
      hide_collected: not is_nil(user),
      items: Gallery.list_items(),
      search: "",
      user: user
    )}
  end

  def handle_params(%{"room" => room}, _uri, socket) do
    socket = assign socket,
      display: nil,
      search: "",
      room: if room == "", do: nil, else: String.to_integer(room)

    {:noreply, assign(socket, visible_items: get_visible_items(socket))}
  end

  def handle_params(_params, uri, socket) do
    if Map.has_key?(socket.assigns, :room),
      do: {:noreply, socket},
      else: handle_params(%{"room" => "1"}, uri, socket)
  end

  def handle_event("search", %{"search_field" => %{"query" => query}}, socket) do
    socket = assign socket, :search, query
    {:noreply, assign(socket, visible_items: get_visible_items(socket))}
  end

  def handle_event("show-display", params, socket) do
    id = if Map.has_key?(params, "id"), do: String.to_integer(params["id"]), else: nil
    socket = assign(socket, :display, id)
    {:noreply, assign(socket, visible_items: get_visible_items(socket))}
  end

  def handle_event("toggle-hide-collected", _params, socket) do
    socket = assign(socket, :hide_collected, !socket.assigns.hide_collected)
    {:noreply, assign(socket, :visible_items, get_visible_items(socket))}
  end

  def handle_event("toggle-item", %{"id" => id}, socket) do
    user = socket.assigns.user
    character = user.active_character

    case Enum.find(socket.assigns.items, & &1.id == String.to_integer(id)) do
      nil ->
        # TODO: Flash an error
        {:noreply, socket}
      item ->
        item_ids = Enum.map(character.items, & &1.id)

        character = if Enum.member?(item_ids, item.id),
          do: Accounts.remove_item(character, item),
          else: Accounts.collect_item(character, item)

        socket = assign(socket, :user, Map.put(user, :active_character, character))
        {:noreply, assign(socket, :visible_items, get_visible_items(socket))}
    end
  end

  defp get_visible_items(socket) do
    # first get all items filtered based on either search or room
    items =
      if socket.assigns.search != "" do
        search = String.downcase(socket.assigns.search)
        Enum.filter(socket.assigns.items, & String.contains?(String.downcase(&1.name), search))
      else
        Enum.filter(socket.assigns.items, & &1.room == socket.assigns.room)
      end

    # then filter items by display if one is selected
    items = if socket.assigns.display,
      do: Enum.filter(items, & &1.display_id == socket.assigns.display),
      else: items

    # if authenticated, attach collected (boolean) and remove collected (if enabled)
    unless is_nil(socket.assigns.user) do
      item_ids = Enum.map(socket.assigns.user.active_character.items, & &1.id)
      items = Enum.map(items, & Map.put(&1, :collected, Enum.member?(item_ids, &1.id)))
      if socket.assigns.hide_collected, do: Enum.reject(items, & &1.collected), else: items
    else
      items
    end
  end
end
