defmodule LotdWeb.GalleryLive do

  use Phoenix.LiveView, container: {:div, class: "container"}
  alias Lotd.{Accounts, Gallery}
  alias LotdWeb.ModalComponent
  alias Lotd.Gallery.{Display, Item, Location, Mod, Region, Room}

  @defaults [
    character_id: nil,
    character_items: nil,
    filter: nil,
    filter_val: nil,
    hide: false,
    moderate: false,
    moderator: false,
    search: ""
  ]

  def render(assigns), do: LotdWeb.GalleryView.render("index.html", assigns)

  def mount(_params, %{"user_id" => user_id }, socket) do
    user = Accounts.get_user!(user_id)

    items = if user.moderator,
      do: Gallery.list_items(),
      else: Gallery.list_items(user.active_character.mods)

    mods = if user.moderator,
      do: Gallery.list_mods(),
      else: list_assoc(items, :mod)

    displays = if user.moderator,
      do: Gallery.list_displays(),
      else: list_assoc(items, :display)

    locations = if user.moderator,
      do: Gallery.list_locations(),
      else: list_assoc(items, :location)

    assigns = [
      character_id: user.active_character.id,
      character_items: user.active_character.items,
      displays: displays,
      items: items,
      locations: locations,
      moderator: user.moderator,
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

  def handle_event("add", %{"type" => type}, socket) do
    send_update(ModalComponent, id: :modal, changeset: Gallery.changeset(type))
    {:noreply, socket}
  end

  def handle_event("edit", %{"id" => id, "type" => type}, socket) do
    send_update(ModalComponent, id: :modal, changeset: Gallery.changeset(type, id))
    {:noreply, socket}
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

  def handle_event("toggle-moderate", _params, socket) do
    {:noreply, assign(socket,
      hide: false,
      moderate: !socket.assigns.moderate
    )}
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

  def handle_event("switch-tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, tab: tab, filter: nil, filter_val: nil)}
  end

  def handle_info({:update_data, object}, socket) do
    case object do
      %Item{} ->
        item = Lotd.Repo.preload(object, [:mod, location: [:region], display: [:room]])
        {:noreply, assign(socket, items: update_entry(socket.assigns.items, item))}

      %Room{} ->
        {:noreply, assign(socket, rooms: update_entry(socket.assigns.rooms, object))}

      %Display{} ->
        display = Lotd.Repo.preload(object, [:room])
        {:noreply, assign(socket, displays: update_entry(socket.assigns.displays, display))}

      %Region{} ->
        {:noreply, assign(socket, regions: update_entry(socket.assigns.regions, object))}

      %Location{} ->
        location = Lotd.Repo.preload(object, [:region])
        {:noreply, assign(socket, locations: update_entry(socket.assigns.locations, location))}

      %Mod{} ->
        {:noreply, assign(socket, mods: update_entry(socket.assigns.mods, object))}
    end
  end

  defp update_entry(collection, object) do
    collection
    |> Enum.reject(& &1.id == object.id)
    |> List.insert_at(0, object)
    |> Enum.sort_by(&(&1.name))
  end
end
