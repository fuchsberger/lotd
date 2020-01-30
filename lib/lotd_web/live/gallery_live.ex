defmodule LotdWeb.GalleryLive do

  use Phoenix.LiveView, container: {:div, class: "container h-100"}
  alias Lotd.{Accounts, Gallery}
  alias Lotd.Gallery.{Display, Item, Location, Mod, Room}

  def render(assigns), do: LotdWeb.GalleryView.render("index.html", assigns)

  def mount(params, socket) do
    user_id = Map.get(params, "user_id")
    user = unless is_nil(user_id), do: Accounts.get_user!(user_id), else: nil
    mods = if is_nil(user), do: Gallery.list_mods(), else: user.active_character.mods

    {:ok, assign(socket,
      changeset: nil,
      displays: Gallery.list_displays(),
      display_filter: nil,
      hide: false,
      items: Gallery.list_items(Enum.map(mods, & &1.id)),
      locations: Gallery.list_locations(),
      location_filter: nil,
      moderate: false,
      mods: mods,
      mod_filter: nil,
      rooms: Gallery.list_rooms(),
      room_filter: nil,
      search: "",
      user: user
    )}
  end

  def handle_event("add", %{"type" => type }, socket) do
    changeset = case type do
      "display" -> Gallery.change_display(%{})
      "item" ->
        Gallery.change_item(%{})
        |> Ecto.Changeset.put_change(:display_id, socket.assigns.display_filter)
        |> Ecto.Changeset.put_change(:location_id, socket.assigns.location_filter)
        |> Ecto.Changeset.put_change(:mod_id, socket.assigns.mod_filter)
        |> Map.put(:action, :insert)
      "location" -> Gallery.change_location(%{})
      "mod" -> Gallery.change_mod(%{})
      "room" -> Gallery.change_room(%{})
    end
    {:noreply, assign(socket, :changeset, Map.put(changeset, :action, :insert))}
  end

  def handle_event("cancel", _params, socket), do:  {:noreply, assign(socket, :changeset, nil)}

  def handle_event("edit", %{"id" => id, "type" => type}, socket) do
    changeset = case type do
      "display" -> Gallery.change_display(Gallery.get_display!(id), %{})
      "item" -> Gallery.change_item(Gallery.get_item!(id), %{})
      "location" -> Gallery.change_location(Gallery.get_location!(id), %{})
      "mod" -> Gallery.change_mod(Gallery.get_mod!(id), %{})
      "room" -> Gallery.change_room(Gallery.get_room!(id), %{})
    end
    {:noreply, assign(socket, :changeset, Map.put(changeset, :action, :update))}
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
    moderate = !socket.assigns.moderate
    mods = if moderate, do: Gallery.list_mods(), else: socket.assigns.user.active_character.mods
    items = Gallery.list_items(Enum.map(mods, & &1.id))
    {:noreply, assign(socket, items: items, moderate: moderate, mod_filter: nil, mods: mods)}
  end

  def handle_event("toggle-item", %{"id" => id}, socket) do
    user = socket.assigns.user
    character = user.active_character

    case Enum.find(socket.assigns.items, & &1.id == String.to_integer(id)) do
      nil ->
        # TODO: Flash an error
        {:noreply, socket}
      item ->
        if Enum.member?(Enum.map(character.items, & &1.id), item.id),
          do: Accounts.remove_item(character, item),
          else: Accounts.collect_item(character, item)

        {:noreply, assign(socket, user: Accounts.get_user!(user.id))}
    end
  end


  def handle_event("validate", params, socket) do
    changeset =
      case socket.assigns.changeset.data do
        %Display{} -> Gallery.change_display(socket.assigns.changeset.data, params["display"])
        %Item{} -> Gallery.change_item(socket.assigns.changeset.data, params["item"])
        %Location{} -> Gallery.change_location(socket.assigns.changeset.data, params["location"])
        %Mod{} -> Gallery.change_mod(socket.assigns.changeset.data, params["mod"])
        %Room{} -> Gallery.change_room(socket.assigns.changeset.data, params["room"])
      end
      |> Map.put(:action, socket.assigns.changeset.action)

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
