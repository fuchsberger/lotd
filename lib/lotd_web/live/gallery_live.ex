defmodule LotdWeb.GalleryLive do

  use Phoenix.LiveView, container: {:div, class: "container"}
  alias Lotd.{Accounts, Gallery}
  alias Lotd.Gallery.{Display, Item, Location, Mod, Room}

  @defaults [
    character_id: nil,
    character_items: nil,
    changeset: nil,
    display_filter: nil,
    hide: false,
    location_filter: nil,
    moderate: false,
    moderator: false,
    mod_filter: nil,
    room_filter: nil,
    search: "",
    user: nil
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

    assigns = [
      character_id: user.active_character.id,
      character_items: user.active_character.items,
      displays: displays,
      items: items,
      locations: list_assoc(items, :location),
      moderator: user.moderator,
      mods: mods,
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

  def handle_event("add", %{"type" => type }, socket) do
    changeset = case type do
      "display" -> Gallery.change_display(%Display{})
      "item" ->
        Gallery.change_item(%Item{})
        |> Ecto.Changeset.put_change(:display_id, socket.assigns.display_filter)
        |> Ecto.Changeset.put_change(:location_id, socket.assigns.location_filter)
        |> Ecto.Changeset.put_change(:mod_id, socket.assigns.mod_filter)
      "location" -> Gallery.change_location(%Location{})
      "mod" -> Gallery.change_mod(%Mod{})
      "room" -> Gallery.change_room(%Room{})
    end

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("cancel", _params, socket), do:  {:noreply, assign(socket, :changeset, nil)}

  def handle_event("edit", %{"id" => id, "type" => type}, socket) do
    changeset = case type do
      "display" -> Gallery.change_display(Gallery.get_display!(id))
      "item" -> Gallery.change_item(Gallery.get_item!(id))
      "location" -> Gallery.change_location(Gallery.get_location!(id))
      "mod" -> Gallery.change_mod(Gallery.get_mod!(id))
      "room" -> Gallery.change_room(Gallery.get_room!(id))
    end
    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("filter", %{"type" => type, "id" => id}, socket) do
    id = if id == "", do: nil, else: String.to_integer(id)
    case type do
      "display" -> {:noreply, assign(socket, display_filter: id)}
      "location" -> {:noreply, assign(socket, location_filter: id)}
      "mod" -> {:noreply, assign(socket, mod_filter: id)}
      "room" -> {:noreply, assign(socket, room_filter: id, display_filter: nil)}
    end
  end

  def handle_event("search", %{"search" => %{"query" => query}}, socket) do
    {:noreply, assign(socket, :search, query)}
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

  def handle_event("validate", params, socket) do
    changeset =
      case socket.assigns.changeset.data do
        %Display{} -> Display.changeset(socket.assigns.changeset.data, params["display"])
        %Item{} -> Item.changeset(socket.assigns.changeset.data, params["item"])
        %Location{} -> Location.changeset(socket.assigns.changeset.data, params["location"])
        %Mod{} -> Mod.changeset(socket.assigns.changeset.data, params["mod"])
        %Room{} -> Room.changeset(socket.assigns.changeset.data, params["room"])
      end

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", _params, socket) do
    case Lotd.Repo.insert_or_update(socket.assigns.changeset) do
      {:ok, object } ->
        socket = assign(socket, :changeset, nil)

        # try to find object in appropriate list and update list
        case object do
          %Display{} ->

            displays =
              socket.assigns.displays
              |> Enum.reject(& &1.id == object.id)
              |> List.insert_at(0, object)
              |> Enum.sort_by(&(&1.name))
            {:noreply, assign(socket, displays: displays)}

          %Item{} ->
            items =
              socket.assigns.items
              |> Enum.reject(& &1.id == object.id)
              |> List.insert_at(0, object)
              |> Enum.sort_by(&(&1.name))

            {:noreply, assign(socket, items: items)}

          %Location{} ->
            locations =
              socket.assigns.locations
              |> Enum.reject(& &1.id == object.id)
              |> List.insert_at(0, object)
              |> Enum.sort_by(&(&1.name))

            {:noreply, assign(socket, locations: locations)}

          %Mod{} ->
            mods =
              socket.assigns.mods
              |> Enum.reject(& &1.id == object.id)
              |> List.insert_at(0, object)
              |> Enum.sort_by(&(&1.name))

            {:noreply, assign(socket, mods: mods)}

          %Room{} ->
            rooms =
              socket.assigns.rooms
              |> Enum.reject(& &1.id == object.id)
              |> List.insert_at(0, object)
              |> Enum.sort_by(&(&1.name))

            {:noreply, assign(socket, rooms: rooms)}
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("delete", _params, socket) do
    id =  socket.assigns.changeset.data.id
    case socket.assigns.changeset.data do
      %Display{} ->
        display = Enum.find(socket.assigns.displays, & &1.id == id)
        case Gallery.delete_display(display) do
          {:ok, _display} ->
            {:noreply, assign(socket, changeset: nil, displays: Gallery.list_displays())}

          {:error, _reason} ->
            {:noreply, socket}
        end

      %Item{} ->
        item = Enum.find(socket.assigns.items, & &1.id == id)
        case Gallery.delete_item(item) do
          {:ok, _item} ->
            {:noreply, assign(socket, changeset: nil, items: Gallery.list_items())}

          {:error, _reason} ->
            {:noreply, socket}
        end

      %Location{} ->
        location = Enum.find(socket.assigns.locations, & &1.id == id)
        case Gallery.delete_location(location) do
          {:ok, _location} ->
            {:noreply, assign(socket, changeset: nil, locations: Gallery.list_locations())}

          {:error, _reason} ->
            {:noreply, socket}
        end

      %Mod{} ->
        mod = Enum.find(socket.assigns.mods, & &1.id == id)
        case Gallery.delete_mod(mod) do
          {:ok, _mod} ->
            {:noreply, assign(socket, changeset: nil, mods: Gallery.list_mods())}

          {:error, _reason} ->
            {:noreply, socket}
        end

      %Room{} ->
        room = Enum.find(socket.assigns.rooms, & &1.id == id)
        case Gallery.delete_room(room) do
          {:ok, _room} ->
            {:noreply, assign(socket, changeset: nil, rooms: Gallery.list_rooms())}

          {:error, _reason} ->
            {:noreply, socket}
        end
    end
  end
end
