defmodule LotdWeb.GalleryLive do

  use Phoenix.LiveView, container: {:div, class: "container-fluid"}

  alias Lotd.{Accounts, Gallery}
  alias Lotd.Gallery.{Room, Region, Display, Location, Mod}

  @defaults [
    tab: "gallery",
    search: ""
  ]

  def render(assigns), do: LotdWeb.GalleryView.render("index.html", assigns)

  def mount(_params, %{"user_id" => user_id }, socket) do
    user = Accounts.get_user!(user_id)

    items = if user.moderator || user.admin,
      do: Gallery.list_items(),
      else: Gallery.list_items(user)

    displays = Gallery.get_displays(items)
    rooms = Gallery.get_rooms(displays)
    locations = Gallery.get_locations(items)
    regions = Gallery.get_regions(locations)
    mods = Gallery.get_mods(items)

    {:ok, socket
    |> assign(@defaults)
    |> assign(:character, user.active_character)
    |> assign(:details, true)
    |> assign(:filter, List.first(rooms))
    |> assign(:hide_changeset, Accounts.hide_changeset(user))
    |> assign(:hide, user.hide)
    |> assign(:items, items)
    |> assign(:displays, displays)
    |> assign(:rooms, rooms)
    |> assign(:locations, locations)
    |> assign(:regions, regions)
    |> assign(:mods, mods)
    |> assign(:user_id, user.id)}
  end

  def mount(_params, _session, socket) do
    items = Gallery.list_items()
    displays = Gallery.get_displays(items)
    rooms = Gallery.get_rooms(displays)
    locations = Gallery.get_locations(items)
    regions = Gallery.get_regions(locations)
    mods = Gallery.get_mods(items)

    {:ok, socket
    |> assign(@defaults)
    |> assign(:character, nil)
    |> assign(:details, true)
    |> assign(:filter, List.first(mods))
    |> assign(:hide, false)
    |> assign(:items, items)
    |> assign(:displays, displays)
    |> assign(:rooms, rooms)
    |> assign(:locations, locations)
    |> assign(:regions, regions)
    |> assign(:mods, mods)}
  end

  def handle_event("filter", %{"type" => type, "id" => id}, socket) do
    {:noreply, socket
    |> assign(filter: Gallery.get(type, id))
    |> assign(search: "")}
  end

  def handle_event("search", %{"search" => %{"query" => query}}, socket) do
    {:noreply, assign(socket, search: query)}
  end

  def handle_event("tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, :tab, tab)}
  end

  def handle_event("clear", _params, socket), do: {:noreply, assign(socket, search: "")}

  def handle_event("toggle", %{"type" => type}, socket) do
    case type do
      "details" ->
        {:noreply, assign(socket, details: !socket.assigns.details)}
    end
  end

  def handle_event("update", %{"user" => %{"hide" => _hide} = params}, socket) do
    case Accounts.toggle_hide(socket.assigns.hide_changeset.data, params) do
      {:ok, user} ->
        {:noreply, socket
        |> assign(:hide, user.hide)
        |> assign(:hide_changeset, Accounts.hide_changeset(user))}

      {:error, changeset} ->
        {:noreply, assign(socket, :hide_changeset, changeset)}
    end
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
