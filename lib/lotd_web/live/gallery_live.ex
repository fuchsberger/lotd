defmodule LotdWeb.GalleryLive do

  use Phoenix.LiveView, container: {:div, class: "container"}
  # use LotdWeb, :live

  alias Lotd.{Accounts, Gallery}

  @defaults [
    character_id: nil,
    character_items: nil,
    filter: nil,
    filter_val: nil,
    hide: false,
    search: ""
  ]

  def render(assigns), do: LotdWeb.GalleryView.render("index.html", assigns)

  def mount(_params, %{"user_id" => user_id }, socket) do
    user = Accounts.get_user!(user_id)

    items = Gallery.list_items(user.active_character)
    mods = list_assoc(items, :mod)
    displays = list_assoc(items, :display)
    locations = list_assoc(items, :location)

    assigns = [
      character_id: user.active_character.id,
      character_items: user.active_character.items,
      displays: displays,
      items: items,
      locations: locations,
      mods: mods,
      regions: list_assoc(locations, :region),
      rooms: list_assoc(displays, :room)
    ]

    {:ok, assign(socket, Keyword.merge(@defaults, assigns))}
  end

  def mount(_params, _session, socket) do

    items = Gallery.list_items()
    displays = list_assoc(items, :display)
    locations = list_assoc(items, :location)

    assigns = [
      items: items,
      rooms: list_assoc(displays, :room),
      displays: displays,
      regions: list_assoc(locations, :region),
      locations: locations,
      mods: list_assoc(items, :mod)
    ]

    {:ok, assign(socket, Keyword.merge(@defaults, assigns))}
  end

  defp list_assoc(collection, assoc) do
    collection
    |> Enum.map(& Map.get(&1, assoc))
    |> Enum.reject(& &1 == nil)
    |> Enum.uniq()
    |> Enum.sort_by(& &1.name, :asc)
  end

  def handle_event("filter", %{"type" => type, "id" => id}, socket) do
    case {type, id} do
      {"", ""} -> {:noreply, assign(socket, filter: nil,  filter_val: nil)}
      {type, ""} -> {:noreply, assign(socket, filter: type, filter_val: nil)}
      {type, id} -> {:noreply, assign(socket, filter: type, filter_val: String.to_integer(id))}
    end
  end

  def handle_event("search", %{"search" => %{"query" => query}}, socket) do
    {:noreply, assign(socket, :search, query)}
  end

  def handle_event("clear-search", _params, socket) do
    {:noreply, assign(socket, :search, "")}
  end

  def handle_event("toggle-hide", _params, socket) do
    {:noreply, assign(socket, :hide, !socket.assigns.hide)}
  end

  def handle_event("toggle-item", %{"id" => id}, socket) do
    id = String.to_integer(id)
    character = Accounts.get_character!(socket.assigns.character_id)
    item = Enum.find(socket.assigns.items, & &1.id == id)

    case Enum.find(character.items, & &1.id == id) do
      nil ->
        Accounts.collect_item(character, item)
        {:noreply, assign(socket, character_items: [id | socket.assigns.character_items])}

      item ->
        Accounts.remove_item(character, item)
        items = List.delete(socket.assigns.character_items, id)
        {:noreply, assign(socket, character_items: items)}
    end
  end
end
