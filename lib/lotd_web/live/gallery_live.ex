defmodule LotdWeb.GalleryLive do

  use Phoenix.LiveView, container: {:div, class: "container-fluid"}

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
    user = Accounts.get_user!(user_id)

    socket = assign(socket, Keyword.merge(@defaults, [
      character: user.active_character,
      hide: user.hide,
      user_id: user_id
    ]))

    {:ok, assign(socket, items: Gallery.list_items(socket.assigns))}
  end

  def mount(_params, _session, socket) do
    socket = assign(socket, Keyword.merge(@defaults, [character: nil, hide: false]))
    {:ok, assign(socket, items: Gallery.list_items(socket.assigns))}
  end

  def handle_event("filter", %{"type" => type, "id" => id}, socket) do
    socket = assign(socket, Keyword.merge(@defaults, [filter: Gallery.get(type, id)]))
    {:noreply, assign(socket, items: Gallery.list_items(socket.assigns))}
  end

  def handle_event("search", %{"search" => %{"query" => query}}, socket) do
    if String.length(query) > 2 do
      socket = assign(socket,
        search: query,
        filter: nil,
        rooms: Gallery.find(Room, query),
        displays: Gallery.find(Display, query),
        regions: Gallery.find(Region, query),
        locations: Gallery.find(Location, query),
        mods: Gallery.find(Mod, query)
      )
      {:noreply, assign(socket, items: Gallery.list_items(socket.assigns))}
    else
      {:noreply, assign(socket, Keyword.merge(@defaults, [search: query]))}
    end
  end

  def handle_event("clear", _params, socket) do
    socket = assign(socket, @defaults)
    {:noreply, assign(socket, items: Gallery.list_items(socket.assigns))}
  end

  def handle_event("toggle-hide", _params, socket) do
    user = Accounts.get_user!(socket.assigns.user_id)
    Accounts.update_user(user, %{hide: !user.hide})

    socket = assign(socket, hide: !user.hide)
    {:noreply, assign(socket, items: Gallery.list_items(socket.assigns))}
  end

  def handle_event("toggle-item", %{"id" => id}, socket) do

    character = Accounts.load_character_items(socket.assigns.character)
    item = Gallery.get_item!(id)

    if Enum.member?(Enum.map(character.items, & &1.id), item.id),
      do: Accounts.remove_item(character, item),
      else: Accounts.collect_item(character, item)

    {:noreply, assign(socket, character: Accounts.get_character!(character.id))}
  end
end
