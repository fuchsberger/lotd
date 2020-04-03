defmodule LotdWeb.GalleryLive do

  use Phoenix.LiveView, container: {:div, class: "container-fluid"}

  alias Lotd.{Accounts, Gallery}
  alias Lotd.Gallery.{Room, Region, Display, Location, Mod}

  def render(assigns), do: LotdWeb.GalleryView.render("index.html", assigns)

  def mount(_params, session, socket) do
    user_id = Map.get(session, "user_id")
    user = if user_id, do: Accounts.get_user!(user_id), else: nil

    hide = if is_nil(user), do: false, else: user.hide

    items = if is_nil(user) || user.moderator || user.admin,
      do: Gallery.list_items(),
      else: Gallery.list_items(user)

    displays = Gallery.get_displays(items)
    rooms = Gallery.get_rooms(displays)
    locations = Gallery.get_locations(items)
    regions = Gallery.get_regions(locations)
    mods = Gallery.get_mods(items)

    {:ok, socket
    |> assign(:character, if is_nil(user) do false else user.active_character end)
    |> assign(:filter, List.first(rooms))
    |> assign(:hide_changeset, Accounts.hide_changeset(user))
    |> assign(:hide, hide)
    |> assign(:items, items)
    |> assign(:displays, displays)
    |> assign(:rooms, rooms)
    |> assign(:locations, locations)
    |> assign(:regions, regions)
    |> assign(:search, "")
    |> assign(:tab, "gallery")
    |> assign(:mods, mods)
    |> assign(:user_id, user.id)
    |> assign(:user, user.id)}
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
