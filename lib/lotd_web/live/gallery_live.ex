defmodule LotdWeb.GalleryLive do

  use Phoenix.LiveView, container: {:div, class: "container h-100"}
  alias Lotd.{Accounts, Gallery}
  alias Lotd.Gallery.{Display, Item, Mod, Room}

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
      items: Gallery.list_items(),
      moderate: true,
      mods: mods,
      mod_filter: nil,
      rooms: Gallery.list_rooms(),
      room_filter: nil,
      search: "",
      user: user
    )}
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
    {:noreply, assign(socket, moderate: moderate, mod_filter: nil, mods: mods)}
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
        {:noreply, assign(socket, :items, Gallery.list_items())}
    end
  end

  # FILTERS
  def handle_event("clear-filter-room", _params, socket) do
    {:noreply, assign(socket, room_filter: nil, display_filter: nil)}
  end

  def handle_event("filter-room", %{"id" => id}, socket) do
    {:noreply, assign(socket, room_filter: String.to_integer(id), display_filter: nil)}
  end

  def handle_event("clear-filter-display", _params, socket) do
    {:noreply, assign(socket, display_filter: nil)}
  end

  def handle_event("filter-display", %{"id" => id}, socket) do
    {:noreply, assign(socket, display_filter: String.to_integer(id))}
  end

  def handle_event("clear-filter-mod", _params, socket) do
    {:noreply, assign(socket, mod_filter: nil)}
  end

  def handle_event("filter-mod", %{"id" => id}, socket) do
    {:noreply, assign(socket, mod_filter: String.to_integer(id))}
  end

  # MODERATION

  def handle_event("cancel", _params, socket), do:  {:noreply, assign(socket, :changeset, nil)}

  def handle_event("validate", params, socket) do
    changeset =
      case socket.assigns.changeset.data do
        %Display{} -> Gallery.change_display(socket.assigns.changeset.data, params["display"])
        %Item{} -> Gallery.change_item(socket.assigns.changeset.data, params["item"])
        %Mod{} -> Gallery.change_mod(socket.assigns.changeset.data, params["mod"])
        %Room{} -> Gallery.change_room(socket.assigns.changeset.data, params["room"])
      end
      |> Map.put(:action, socket.assigns.changeset.action)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("add-room", _params, socket) do
    changeset = Gallery.change_room(%{}) |> Map.put(:action, :insert)
    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("create_room", %{"room" => room_params}, socket) do
    case Gallery.create_room(room_params) do
      {:ok, _room } ->
        {:noreply, assign(socket, changeset: nil, rooms: Gallery.list_rooms())}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("edit-room", %{"id" => id}, socket) do
    changeset = Gallery.change_room(Gallery.get_room!(id), %{}) |> Map.put(:action, :update)
    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("update_room", %{"room" => room_params}, socket) do
    case Gallery.update_room(socket.assigns.changeset.data, room_params) do
      {:ok, _room } ->
        {:noreply, assign(socket, changeset: nil, rooms: Gallery.list_rooms())}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("delete-room", %{"id" => id}, socket) do
    case Gallery.delete_room(Enum.find(socket.assigns.rooms, & &1.id == String.to_integer(id))) do
      {:ok, _room} ->
        {:noreply, assign(socket, changeset: nil, rooms: Gallery.list_rooms())}

      {:error, _reason} ->
        {:noreply, socket}
    end
  end

  def handle_event("add-display", _params, socket) do
    changeset = Gallery.change_display(%{}) |> Map.put(:action, :insert)
    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("create_display", %{"display" => display_params}, socket) do
    case Gallery.create_display(display_params) do
      {:ok, _display } ->
        {:noreply, assign(socket, changeset: nil, displays: Gallery.list_displays())}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("edit-display", %{"id" => id}, socket) do
    changeset = Gallery.change_display(Gallery.get_display!(id), %{}) |> Map.put(:action, :update)
    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("update_display", %{"display" => display_params}, socket) do
    case Gallery.update_display(socket.assigns.changeset.data, display_params) do
      {:ok, _display } ->
        {:noreply, assign(socket, changeset: nil, displays: Gallery.list_displays())}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("delete-display", %{"id" => id}, socket) do
    display = Enum.find(socket.assigns.displays, & &1.id == String.to_integer(id))
    case Gallery.delete_display(display) do
      {:ok, _display} ->
        {:noreply, assign(socket, changeset: nil, displays: Gallery.list_displays())}

      {:error, _reason} ->
        {:noreply, socket}
    end
  end

  def handle_event("add-mod", _params, socket) do
    changeset = Gallery.change_mod(%{}) |> Map.put(:action, :insert)
    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("create_mod", %{"mod" => mod_params}, socket) do
    case Gallery.create_mod(mod_params) do
      {:ok, _mod } ->
        {:noreply, assign(socket, changeset: nil, mods: Gallery.list_mods())}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("edit-mod", %{"id" => id}, socket) do
    changeset = Gallery.change_mod(Gallery.get_mod!(id), %{}) |> Map.put(:action, :update)
    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("update_mod", %{"mod" => mod_params}, socket) do
    case Gallery.update_mod(socket.assigns.changeset.data, mod_params) do
      {:ok, _mod } ->
        {:noreply, assign(socket, changeset: nil, mods: Gallery.list_mods())}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("delete-mod", %{"id" => id}, socket) do
    mod = Enum.find(socket.assigns.mods, & &1.id == String.to_integer(id))
    case Gallery.delete_mod(mod) do
      {:ok, _mod} ->
        {:noreply, assign(socket, changeset: nil, mods: Gallery.list_mods())}

      {:error, _reason} ->
        {:noreply, socket}
    end
  end

  def handle_event("add-item", _params, socket) do
    changeset =
      Gallery.change_item(%{})
      |> Ecto.Changeset.put_change(:mod_id, 1)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("create_item", %{"item" => item_params}, socket) do
    case Gallery.create_item(item_params) do
      {:ok, _item } ->
        {:noreply, assign(socket, changeset: nil, items: Gallery.list_items())}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("edit-item", %{"id" => id}, socket) do
    changeset = Gallery.change_item(Gallery.get_item!(id), %{}) |> Map.put(:action, :update)
    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("update_item", %{"item" => item_params}, socket) do
    case Gallery.update_item(socket.assigns.changeset.data, item_params) do
      {:ok, _item } ->
        {:noreply, assign(socket, changeset: nil, items: Gallery.list_items())}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("delete-item", %{"id" => id}, socket) do
    item = Enum.find(socket.assigns.items, & &1.id == String.to_integer(id))

    case socket.assigns.user.moderator && Gallery.delete_item(item) do
      {:ok, _item} ->
        {:noreply, assign(socket, changeset: nil, items: Gallery.list_items())}

      {:error, _reason} ->
        {:noreply, socket}
    end
  end
end
