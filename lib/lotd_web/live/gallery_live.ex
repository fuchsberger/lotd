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

    assigns = [
      displays: displays,
      items: items,
      locations: list_assoc(items, :location),
      mods: list_assoc(items, :mod),
      rooms: list_assoc(displays, :room)
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
        items =
          socket.assigns.items
          |> Enum.reject(& &1.id == item.id)
          |> List.insert_at(0, item)
          |> Enum.sort_by(&(&1.name))
        {:noreply, assign(socket, items: items)}

    end
  end
end

        # try to find object in appropriate list and update list
        # case object do
        #   %Display{} ->

        #     displays =
        #       socket.assigns.displays
        #       |> Enum.reject(& &1.id == object.id)
        #       |> List.insert_at(0, object)
        #       |> Enum.sort_by(&(&1.name))
        #     {:noreply, assign(socket, displays: displays)}

        #   %Item{} ->


        #     # socket.assigns.card | title: title}}

        #   %Location{} ->
        #     locations =
        #       socket.assigns.locations
        #       |> Enum.reject(& &1.id == object.id)
        #       |> List.insert_at(0, object)
        #       |> Enum.sort_by(&(&1.name))

        #     {:noreply, assign(socket, locations: locations)}

        #   %Mod{} ->
        #     mods =
        #       socket.assigns.mods
        #       |> Enum.reject(& &1.id == object.id)
        #       |> List.insert_at(0, object)
        #       |> Enum.sort_by(&(&1.name))

        #     {:noreply, assign(socket, mods: mods)}

        #   %Room{} -> "room"
        #     rooms =
        #       socket.assigns.rooms
        #       |> Enum.reject(& &1.id == object.id)
        #       |> List.insert_at(0, object)
        #       |> Enum.sort_by(&(&1.name))

        #     {:noreply, assign(socket, rooms: rooms)}
        # end

