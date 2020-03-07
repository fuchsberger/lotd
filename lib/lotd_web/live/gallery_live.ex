defmodule LotdWeb.GalleryLive do

  use Phoenix.LiveView, container: {:div, class: "container-fluid"}
  # use LotdWeb, :live

  alias Lotd.{Accounts, Gallery}
  alias Lotd.Gallery.{Room, Region, Display, Location, Mod}

  @defaults [
    filter: nil,
    search: "",
    rooms: [],
    displays: [],
    regions: [],
    locations: [],
    mods: []
  ]

  def render(assigns), do: LotdWeb.GalleryView.render("index.html", assigns)

  def mount(_params, %{"user_id" => user_id }, socket) do
    character = Accounts.get_user!(user_id).active_character
    assigns = [
      character: character,
      hide: false,
      items: Gallery.list_items(Keyword.get(@defaults, :search), character),
    ]
    {:ok, assign(socket, Keyword.merge(@defaults, assigns))}
  end

  def mount(_params, _session, socket) do
    assigns = [
      character: nil,
      hide: false,
      items: Gallery.list_items(Keyword.get(@defaults, :search), nil)
    ]
    {:ok, assign(socket, Keyword.merge(@defaults, assigns))}
  end

  def handle_event("filter", %{"type" => type, "id" => id}, socket) do
    filter = Gallery.get(type, id)

    assigns = @defaults
    |> Keyword.put(:filter, filter)
    |> Keyword.put(:items, Gallery.list_items(type, id, socket.assigns.character))

    {:noreply, assign(socket, assigns)}
  end

  def handle_event("search", %{"search" => %{"query" => query}}, socket) do
    filter = String.length(query) > 2
    {:noreply, assign(socket,
      search: query,
      filter: nil,
      items: Gallery.list_items(query, socket.assigns.character),
      rooms: (if filter, do: Gallery.find(Room, query), else: []),
      displays: (if filter, do: Gallery.find(Display, query), else: []),
      regions: (if filter, do: Gallery.find(Region, query), else: []),
      locations: (if filter, do: Gallery.find(Location, query), else: []),
      mods: (if filter, do: Gallery.find(Mod, query), else: [])
    )}
  end

  def handle_event("clear", _params, socket) do
    {:noreply, assign(socket,
      Keyword.put(@defaults, :items, Gallery.list_items("", socket.assigns.character))
    )}
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
