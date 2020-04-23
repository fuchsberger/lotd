defmodule LotdWeb.GalleryLive do

  use Phoenix.LiveView, container: {:div, class: "container"}

  alias Lotd.{Accounts, Gallery}
  alias Lotd.Accounts.Character

  def render(assigns), do: LotdWeb.GalleryView.render("index.html", assigns)

  def mount(_params, session, socket) do

    user = if user_id = Map.get(session, "user_id"), do: Accounts.get_user!(user_id), else: nil

    socket
    |> assign(:changeset, nil)
    |> assign(:filter, nil)
    |> assign(:search, "")
    |> assign(:tab, 1)
    |> assign(:user, user)
    |> sync_lists(:ok)
  end

  defp active_character(socket), do: socket.assigns.user && Enum.find(socket.assigns.user.characters, & &1.id == socket.assigns.user.active_character_id)

  def handle_event("add", %{"type" => type}, socket) do
    if is_nil(socket.assigns.changeset),
      do: {:noreply, assign(socket, :changeset, Gallery.changeset(type))},
      else: {:noreply, assign(socket, :changeset, nil)}
  end

  def handle_event("activate", %{"character" => id}, socket) do
    case Accounts.update_user(socket.assigns.user, %{active_character_id: id}) do
      {:ok, %{id: id}} -> {:noreply, assign(socket, :user, Accounts.get_user!(id))}
      {:error, _reason} -> {:noreply, socket}
    end
  end

  def handle_event("activate", %{"mod" => id}, socket) do
    mod =
      socket.assigns.active_mods
      |> Enum.concat(socket.assigns.mods)
      |> Enum.find(& &1.id == String.to_integer(id))

    case Accounts.activate_mod(active_character(socket), mod) do
      {:ok, _character} ->
        socket
        |> assign(:user, Accounts.get_user!(socket.assigns.user.id))
        |> sync_lists()

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  def handle_event("deactivate", %{"mod" => id}, socket) do
    mod =
      socket.assigns.active_mods
      |> Enum.concat(socket.assigns.mods)
      |> Enum.find(& &1.id == String.to_integer(id))

    case Accounts.deactivate_mod(active_character(socket), mod) do
      {:ok, _character} ->
        socket
        |> assign(:user, Accounts.get_user!(socket.assigns.user.id))
        |> sync_lists()

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  def handle_event("clear", %{"filter" => _}, socket) do
    socket
    |> assign(:filter, nil)
    |> sync_lists()
  end

  def handle_event("clear", %{"search" => _}, socket) do
    socket
    |> assign(:search, "")
    |> sync_lists()
  end

  def handle_event("filter", %{"region" => id}, socket) do
    region = Enum.find(socket.assigns.regions, & &1.id == String.to_integer(id))

    changeset = if socket.assigns.changeset && Map.has_key?(socket.assigns.changeset.data, :region_id),
      do: Ecto.Changeset.change(socket.assigns.changeset, %{region_id: region.id, region_name: region.name}),
      else: socket.assigns.changeset

    filter = {:region, region.id}

    socket
    |> assign(:changeset, changeset)
    |> assign(:filter, (if filter == socket.assigns.filter, do: nil, else: filter))
    |> sync_lists()
  end

  def handle_event("filter", %{"room" => id}, socket) do
    room = Enum.find(socket.assigns.rooms, & &1.id == String.to_integer(id))

    changeset = if socket.assigns.changeset && Map.has_key?(socket.assigns.changeset.data, :room_id),
      do: Ecto.Changeset.change(socket.assigns.changeset, %{room_id: room.id, room_name: room.name}),
      else: socket.assigns.changeset

    filter = {:room, room.id}

    socket
    |> assign(:changeset, changeset)
    |> assign(:filter, (if filter == socket.assigns.filter, do: nil, else: filter))
    |> sync_lists()
  end

  def handle_event("filter", %{"location" => id}, socket) do
    location = Enum.find(socket.assigns.locations, & &1.id == String.to_integer(id))

    changeset = if socket.assigns.changeset && Map.has_key?(socket.assigns.changeset.data, :location_id),
      do: Ecto.Changeset.change(socket.assigns.changeset, %{
        location_id: location.id,
        location_name: location.name
      }),
      else: socket.assigns.changeset

    filter = {:location, location.id}

    socket
    |> assign(:changeset, changeset)
    |> assign(:filter, (if filter == socket.assigns.filter, do: nil, else: filter))
    |> sync_lists()
  end

  def handle_event("filter", %{"display" => id}, socket) do
    display = Enum.find(socket.assigns.displays, & &1.id == String.to_integer(id))

    changeset = if socket.assigns.changeset && Map.has_key?(socket.assigns.changeset.data, :display_id),
      do: Ecto.Changeset.change(socket.assigns.changeset, %{
        display_id: display.id,
        display_name: display.name
      }),
      else: socket.assigns.changeset

    filter = {:display, display.id}

    socket
    |> assign(:changeset, changeset)
    |> assign(:filter, (if filter == socket.assigns.filter, do: nil, else: filter))
    |> sync_lists()
  end

  def handle_event("filter", %{"mod" => id}, socket) do
    mod = Enum.find(socket.assigns.active_mods ++ socket.assigns.mods, & &1.id == String.to_integer(id))

    changeset = if socket.assigns.changeset && Map.has_key?(socket.assigns.changeset.data, :mod_id),
      do: Ecto.Changeset.change(socket.assigns.changeset, %{mod_id: mod.id, mod_name: mod.name}),
      else: socket.assigns.changeset

    filter = {:mod, mod.id}

    socket
    |> assign(:changeset, changeset)
    |> assign(:filter, (if filter == socket.assigns.filter, do: nil, else: filter))
    |> sync_lists()
  end

  def handle_event("search", %{"search" => %{"query" => query}}, socket) do
    socket
    |> assign(:search, query)
    |> sync_lists()
  end

  def handle_event("tab", %{"tab" => tab}, socket) do
    socket
    |> assign(:tab, String.to_integer(tab))
    |> sync_lists()
  end

  def handle_event("toggle", %{"item" => id}, socket) do
    character = active_character(socket)
    item = Enum.find(socket.assigns.items, & &1.id == String.to_integer(id))

    if Enum.member?(character.items, item.id),
      do: Accounts.remove_item(character, item),
      else: Accounts.collect_item(character, item)

    {:noreply, assign(socket, :user, Accounts.get_user!(socket.assigns.user.id))}
  end

  def handle_event("toggle", %{"hide" => _}, socket) do
    case Accounts.update_user(socket.assigns.user, %{hide: !socket.assigns.user.hide}) do
      {:ok, _user} ->
        socket
        |> assign(:user, Accounts.get_user!(socket.assigns.user.id))
        |> sync_lists()

      {:error, _changeset} -> {:noreply, socket}
    end
  end

  def handle_event("toggle", %{"moderate" => _}, socket) do
    {:noreply, assign(socket, :moderate, !socket.assigns.moderate)}
  end

  def handle_event("edit", params, socket) do
    changeset =
      case params do
        %{"character" => id} ->
          socket.assigns.user.characters
          |> Enum.find(& &1.id == String.to_integer(id))
          |> Accounts.change_character()

        %{"display" => id} ->
          display = Enum.find(socket.assigns.displays, & &1.id == String.to_integer(id))
          room = Enum.find(socket.assigns.regions, & &1.id == display.region_id)
          Gallery.change_display(display, %{room_id: room.id, room_name: room.name})

        %{"location" => id} ->
          location = Enum.find(socket.assigns.locations, & &1.id == String.to_integer(id))
          region = Enum.find(socket.assigns.regions, & &1.id == location.region_id)
          Gallery.change_location(location, %{region_id: region.id, region_name: region.name})

        %{"room" => id} ->
          socket.assigns.rooms
          |> Enum.find(& &1.id == String.to_integer(id))
          |> Gallery.change_room()

        %{"region" => id} ->
          socket.assigns.regions
          |> Enum.find(& &1.id == String.to_integer(id))
          |> Gallery.change_region()

        %{"mod" => id} ->
          socket.assigns.active_mods ++ socket.assigns.mods
          |> Enum.find(& &1.id == String.to_integer(id))
          |> Gallery.change_mod(%{})
      end
    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("cancel", _params, socket), do: {:noreply, assign(socket, :changeset, nil)}

  def handle_event("validate", params, socket) do
    data = socket.assigns.changeset.data
    changeset =
      case params do
        %{"character" => params} -> Accounts.change_character data, params
        %{"item" => params} ->      Gallery.change_item       data, params
        %{"display" => params} ->   Gallery.change_display    data, params
        %{"room" => params} ->      Gallery.change_room       data, params
        %{"location" => params} ->  Gallery.change_location   data, params
        %{"region" => params} ->    Gallery.change_region     data, params
        %{"mod" => params} ->       Gallery.change_mod        data, params
      end
    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", _params, socket) do
    changeset =
      if socket.assigns.changeset.data.__struct__ == Character,
        do: Ecto.Changeset.change(socket.assigns.changeset, %{user_id: socket.assigns.user.id}),
        else: socket.assigns.changeset

    case Lotd.Repo.insert_or_update(changeset) do
      {:ok, _entry} ->
        socket
        |> assign(:changeset, nil)
        |> assign(:user, Accounts.get_user!(socket.assigns.user.id))
        |> sync_lists()

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_event("delete", %{"character" => id}, socket) do
    character = Enum.find(socket.assigns.user.characters, & &1.id == String.to_integer(id))
    case Accounts.delete_character(character) do
      {:ok, _character} ->
        {:noreply, assign(socket, :user, Accounts.get_user!(socket.assigns.user.id))}

      {:error, _reason} ->
        {:noreply, socket}
    end
  end

  def handle_event("delete", _params, socket) do
    case Lotd.Repo.delete(socket.assigns.changeset.data) do
      {:ok, _struct} ->
        socket
        |> assign(:changeset, nil)
        |> assign(:filter, nil)
        |> assign(:user, Accounts.get_user!(socket.assigns.user.id))
        |> sync_lists()

      {:error, _reason} -> socket
    end
  end

  defp sync_lists(socket, return \\ :noreply) do
    {return, socket
    |> assign(:items, Gallery.list_items(socket.assigns.user, socket.assigns.search, socket.assigns.filter))
    |> sync_displays()
    |> sync_locations()
    |> sync_mods()}
  end

  defp sync_displays(%{assigns: %{filter: filter, search: search, tab: tab}} = socket) do

    if tab == 1 || String.length(search) > 2 do

      rooms = case searching?(socket) do
        true -> Gallery.list_rooms(search)
        false -> Gallery.list_rooms()
      end

      c_items = socket.assigns.user && socket.assigns.user.hide && active_character(socket).items

      displays = case searching?(socket) do
        true -> Gallery.list_displays(c_items, search)
        false -> Gallery.list_displays(c_items, filter)
      end

      socket
      |> assign(:rooms, rooms)
      |> assign(:displays, displays)
    else
      socket
      |> assign(:rooms, [])
      |> assign(:displays, [])
    end
  end

  defp sync_locations(%{assigns: %{filter: filter, search: search, tab: tab}} = socket) do

    if tab == 2 || String.length(search) > 2 do

      regions = case searching?(socket) do
        true -> Gallery.list_regions(search)
        false -> Gallery.list_regions()
      end

      c_items = socket.assigns.user && socket.assigns.user.hide && active_character(socket).items

      locations = case searching?(socket) do
        true -> Gallery.list_locations(c_items, search)
        false -> Gallery.list_locations(c_items, filter)
      end

      socket
      |> assign(:regions, regions)
      |> assign(:locations, locations)
    else
      socket
      |> assign(:regions, [])
      |> assign(:locations, [])
    end
  end

  defp sync_mods(%{assigns: %{search: search, tab: tab, user: user}} = socket) do

    if tab == 3 || searching?(socket) do

      character = active_character(socket)

      mods = case {user && user.hide, searching?(socket)} do
        {true, true} -> Gallery.list_mods(character.items, search)
        {true, false} -> Gallery.list_mods(character.items)
        {false, true} -> Gallery.list_mods(search)
        {false, false} -> Gallery.list_mods()
      end

      if character && not searching?(socket) do
        grouped = Enum.group_by(mods, & Enum.member?(character.mods, &1.id) && &1.item_count > 0)
        socket
        |> assign(:active_mods, Map.get(grouped, true, []))
        |> assign(:mods, Map.get(grouped, false, []))
      else
        socket
        |> assign(:active_mods, [])
        |> assign(:mods, mods)
      end
    else
      socket
      |> assign(:active_mods, [])
      |> assign(:mods, [])
    end
  end

  defp searching?(socket), do: String.length(socket.assigns.search) > 2
end
