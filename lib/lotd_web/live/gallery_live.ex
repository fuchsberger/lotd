defmodule LotdWeb.GalleryLive do

  use Phoenix.LiveView, layout: {LotdWeb.LayoutView, "live.html"}

  alias LotdWeb.Router.Helpers, as: Routes
  alias Lotd.{Accounts, Gallery, Repo}
  alias Lotd.Accounts.Character
  alias Lotd.Gallery.{Item, Display, Location, Mod, Room, Region}

  def render(assigns), do: Phoenix.View.render(LotdWeb.GalleryView, "main.html", assigns)

  def mount(_params, session, socket) do

    socket =
      case Map.get(session, "user_id") do
        nil ->
          socket
          |> assign(:authenticated?, false)

        user_id ->
          user = Accounts.get_user!(user_id)

          IO.inspect user.active_character

          socket
          |> assign(:authenticated?, true)
          |> assign(:character_mods, Gallery.list_character_mod_ids(user.active_character))
          |> assign(:user, user)
      end

    {:ok, socket
    |> assign(:changeset, nil)
    |> assign(:filter, nil)
    # |> assign(:items, Gallery.list_items(user))
    |> assign(:mods, Gallery.list_mods())
    # |> assign(:mod_options, Gallery.list_mod_options())
    |> assign(:locked?, true)
    |> assign(:page_title, "LOTD Tracker")
    |> assign(:show_help?, false)
    |> assign(:show_search?, false)
    |> assign(:show_menu?, false)
    |> assign(:search, "")
    |> assign(:tab, 3)}
  end

  def handle_params(_params, _uri, socket) do
    case socket.assigns.live_action do
      :index ->
        {:noreply, push_patch(socket, to: Routes.gallery_path(socket, :hall_of_heroes))}

      action ->
        # set and assign page title
        title = action |> Atom.to_string() |> String.capitalize()

        {:noreply, socket
        |> assign(:show_help?, false)
        |> assign(:show_menu?, false)
        |> assign(:page_title, title)}
    end
  end

  defp active_character(socket), do: socket.assigns.user && Enum.find(socket.assigns.user.characters, & &1.id == socket.assigns.user.active_character_id)

  def handle_event("add", %{"type" => type}, socket) do
    if is_nil(socket.assigns.changeset) do
      case type do
        "item" ->
          {:noreply, socket
          |> assign(:changeset, Gallery.change_item(%Item{}, %{}))
          |> assign(:display_options, Gallery.list_display_options())
          |> assign(:location_options, Gallery.list_location_options())}

        "character" ->
          {:noreply, assign(socket, :changeset, Accounts.change_character(%Character{}))}

        "display" ->
          {:noreply, socket
          |> assign(:changeset, Gallery.change_display(%Display{}))
          |> assign(:room_options, Gallery.list_room_options())}

        "room" ->
          {:noreply, assign(socket, :changeset, Gallery.change_room(%Room{}))}

        "location" ->
          {:noreply, socket
          |> assign(:changeset, Gallery.change_location(%Location{}))
          |> assign(:region_options, Gallery.list_region_options())}

        "region" ->
          {:noreply, assign(socket, :changeset, Gallery.change_region(%Region{}))}

        "mod" ->
          {:noreply, assign(socket, :changeset, Gallery.change_mod(%Mod{}))}
      end
    else
      {:noreply, assign(socket, :changeset, nil)}
    end
  end

  def handle_event("activate", %{"character" => id}, socket) do
    case Accounts.update_user(socket.assigns.user, %{active_character_id: id}) do
      {:ok, _user} ->
        user = Accounts.get_user!(socket.assigns.user.id)

        {:noreply, socket
        |> assign(:items, Gallery.list_items(user))
        |> assign(:user, user)}

      {:error, _reason} ->
        {:noreply, socket}
    end
  end

  def handle_event("clear", %{"filter" => _}, socket) do
    {:noreply, assign(socket, :filter, nil)}
  end

  def handle_event("clear", %{"search" => _}, socket) do
    {:noreply, assign(socket, :search, "")}
  end

  def handle_event("filter", %{"region" => id}, socket) do

    changeset = if socket.assigns.changeset && Map.has_key?(socket.assigns.changeset.data, :region_id) do
      region = Gallery.get_region!(String.to_integer(id))
      Ecto.Changeset.change(socket.assigns.changeset, %{
        region_id: region.id,
        region_name: region.name
      })
    else socket.assigns.changeset end

    {:noreply, socket
    |> assign(:changeset, changeset)
    |> assign(:filter, {:region, String.to_integer(id)})
    |> assign(:search, "")
    |> assign(:tab, 2)}
  end

  def handle_event("filter", %{"room" => id}, socket) do

    changeset = if socket.assigns.changeset && Map.has_key?(socket.assigns.changeset.data, :room_id) do
      room = Gallery.get_room!(String.to_integer(id))
      Ecto.Changeset.change(socket.assigns.changeset, %{room_id: room.id, room_name: room.name})
    else
      socket.assigns.changeset
    end

    {:noreply, socket
    |> assign(:changeset, changeset)
    |> assign(:filter, {:room, String.to_integer(id)})
    |> assign(:search, "")
    |> assign(:tab, 1)}
  end

  def handle_event("filter", %{"location" => id}, socket) do
    changeset = if socket.assigns.changeset && Map.has_key?(socket.assigns.changeset.data, :location_id) do
      location = Gallery.get_location!(String.to_integer(id))
      Ecto.Changeset.change(socket.assigns.changeset, %{location_id: location.id})
    else
      socket.assigns.changeset
    end

    {:noreply, socket
    |> assign(:changeset, changeset)
    |> assign(:filter, {:location, String.to_integer(id)})
    |> assign(:search, "")
    |> assign(:tab, 2)}
  end

  def handle_event("filter", %{"display" => id}, socket) do
    changeset = if socket.assigns.changeset && Map.has_key?(socket.assigns.changeset.data, :display_id) do
      display = Gallery.get_display!(String.to_integer(id))
      Ecto.Changeset.change(socket.assigns.changeset, %{display_id: display.id})
    else
      socket.assigns.changeset
    end

    {:noreply, socket
    |> assign(:changeset, changeset)
    |> assign(:filter, {:display, String.to_integer(id)})
    |> assign(:search, "")
    |> assign(:tab, 1)}
  end

  def handle_event("filter", %{"mod" => id}, socket) do

    changeset = if socket.assigns.changeset && Map.has_key?(socket.assigns.changeset.data, :mod_id) do
      mod = Gallery.get_mod!(String.to_integer(id))
      Ecto.Changeset.change(socket.assigns.changeset, %{mod_id: mod.id})
    else
      socket.assigns.changeset
    end

    {:noreply, socket
    |> assign(:changeset, changeset)
    |> assign(:filter, {:mod, String.to_integer(id)})
    |> assign(:search, "")
    |> assign(:tab, 3)}
  end

  def handle_event("search", %{"search" => %{"query" => query}}, socket) do
    {:noreply, assign(socket, :search, query)}
  end

  def handle_event("tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, :tab, String.to_integer(tab))}
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
        {:noreply, assign(socket, :user, Accounts.get_user!(socket.assigns.user.id))}

      {:error, _changeset} -> {:noreply, socket}
    end
  end

  def handle_event("toggle", %{"type" => type}, socket) do
    case type do
      "locked" -> {:noreply, assign(socket, :locked?, !socket.assigns.locked?)}
      "help" -> {:noreply, assign(socket, :show_help?, !socket.assigns.show_help?)}
      "menu" -> {:noreply, assign(socket, :show_menu?, !socket.assigns.show_menu?)}
    end
  end

  def handle_event("toggle", %{"mod" => id}, socket) do
    mod = Enum.find(socket.assigns.mods, & &1.id == String.to_integer(id))
    character_mods = Accounts.toggle_character_mod(socket.assigns.user.active_character, mod)
    {:noreply, assign(socket, :character_mods, character_mods)}
  end

  def handle_event("toggle", %{"moderate" => _}, socket) do
    {:noreply, assign(socket, :moderate, !socket.assigns.moderate)}
  end

  def handle_event("edit", %{"display" => id}, socket) do
    display = Gallery.get_display!(id)

    {:noreply, socket
    |> assign(:changeset, Gallery.change_display(display, %{}))
    |> assign(:room_options, Gallery.list_room_options())}
  end

  def handle_event("edit", %{"location" => id}, socket) do
    {:noreply, socket
    |> assign(:changeset, Gallery.change_location(Gallery.get_location!(id), %{}))
    |> assign(:region_options, Gallery.list_region_options())}
  end

  def handle_event("edit", %{"item" => id}, socket) do
    {:noreply, socket
    |> assign(:changeset, Gallery.change_item(Gallery.get_item!(id), %{}))
    |> assign(:display_options, Gallery.list_display_options())
    |> assign(:location_options, Gallery.list_location_options())}
  end

  def handle_event("edit", %{"mod" => id}, socket) do
    {:noreply, assign(socket, :changeset, Gallery.change_mod(Gallery.get_mod!(id), %{}))}
  end

  def handle_event("edit", %{"region" => id}, socket) do
    {:noreply, assign(socket, :changeset, Gallery.change_region(Gallery.get_region!(id), %{}))}
  end

  def handle_event("edit", %{"room" => id}, socket) do
    {:noreply, assign(socket, :changeset, Gallery.change_room(Gallery.get_room!(id), %{}))}
  end

  def handle_event("edit", %{"character" => id}, socket) do
    character = Enum.find(socket.assigns.user.characters, & &1.id == String.to_integer(id))
    {:noreply, assign(socket, :changeset, Accounts.change_character(character))}
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

  def handle_event("save", params, socket) do

    data = socket.assigns.changeset.data
    changeset =
      case params do
        %{"character" => params} ->
          Accounts.change_character data, Map.put(params, "user_id", socket.assigns.user.id)
        %{"item" => params} ->      Gallery.change_item       data, params
        %{"display" => params} ->   Gallery.change_display    data, params
        %{"room" => params} ->      Gallery.change_room       data, params
        %{"location" => params} ->  Gallery.change_location   data, params
        %{"region" => params} ->    Gallery.change_region     data, params
        %{"mod" => params} ->       Gallery.change_mod        data, params
      end

    case Repo.insert_or_update(changeset) do
      {:ok, _entry} ->
        {:noreply, socket
        |> assign(:changeset, nil)
        |> assign(:items, Gallery.list_items(socket.assigns.user))
        |> assign(:user, Accounts.get_user!(socket.assigns.user.id))}

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
    case Repo.delete(socket.assigns.changeset.data) do
      {:ok, _struct} ->
        {:noreply, socket
        |> assign(:changeset, nil)
        |> assign(:filter, nil)
        |> assign(:user, Accounts.get_user!(socket.assigns.user.id))}

      {:error, _reason} -> socket
    end
  end
end
