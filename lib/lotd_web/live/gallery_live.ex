defmodule LotdWeb.GalleryLive do

  use Phoenix.LiveView, container: {:div, class: "container-fluid"}

  alias Lotd.{Accounts, Gallery}
  alias Lotd.Accounts.Character
  alias Lotd.Gallery.{Room, Region, Display, Location, Mod}

  @filters %{
    filter_item: nil,
    filter_display: nil,
    filter_room: nil,
    filter_location: nil,
    filter_region: nil,
    filter_mod: nil
  }

  def render(assigns), do: LotdWeb.GalleryView.render("index.html", assigns)

  def mount(_params, session, socket) do
    user_id = Map.get(session, "user_id")
    user = if user_id, do: Accounts.get_user!(user_id), else: nil
    character = user && user.active_character

    socket
    |> assign(@filters)
    |> assign(:admin, user && user.admin)
    |> assign(:character, character)
    |> assign(:characters, user && Accounts.list_characters(user.id))
    |> assign(:character_item_ids, user && Accounts.get_character_item_ids(character))
    |> assign(:character_mod_ids, user && Accounts.get_character_mod_ids(character))
    |> assign(:changeset, nil)
    |> assign(:hide, user && user.hide)
    |> assign(:moderate, false)
    |> assign(:moderator, user && user.moderator)
    |> assign(:mods, Gallery.list_mods())
    |> assign(:rooms, Gallery.list_regions())
    |> assign(:regions, Gallery.list_regions())
    |> assign(:search, "")
    |> assign(:tab, 2)
    |> sync_lists(:ok)
  end

  def handle_event("filter", params, socket) do
    filters =
      case params do
        %{"display" => id} ->
          @filters
          |> Map.put(:filter_room, socket.assigns.filter_room)
          |> Map.put(:filter_display, String.to_integer(id))

        %{"room" => id} ->
          Map.put(@filters, :filter_room, String.to_integer(id))

        %{"location" => id} ->
          @filters
          |> Map.put(:filter_region, socket.assigns.filter_region)
          |> Map.put(:filter_location, String.to_integer(id))

        %{"region" => id} ->
          Map.put(@filters, :filter_region, String.to_integer(id))

        %{"mod" => id} ->
          Map.put(@filters, :filter_mod, String.to_integer(id))
      end

    socket
    |> assign(filters)
    |> sync_lists()
  end

  def handle_event("search", %{"search" => %{"query" => query}}, socket) do
    {:noreply, assign(socket, search: query)}
  end

  def handle_event("tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, :tab, String.to_integer(tab))}
  end

  def handle_event("clear", _params, socket), do: {:noreply, assign(socket, search: "")}

  def handle_event("toggle-item", %{"id" => id}, socket) do

    character = Accounts.load_character_items(socket.assigns.user.active_character)
    item = Gallery.get_item!(id)

    if Enum.member?(Enum.map(character.items, & &1.id), item.id),
      do: Accounts.remove_item(character, item),
      else: Accounts.collect_item(character, item)

    {:noreply, assign(socket, :user,
      Map.put(socket.assigns.user, :active_character, Accounts.get_character!(character.id)))}
  end

  def handle_event("toggle", %{"hide" => _}, socket) do
    user = Accounts.get_user(socket.assigns.character.user_id)
    case Accounts.update_user(user, %{hide: !socket.assigns.hide}) do
      {:ok, user} ->
        socket
        |> assign(:hide, user.hide)
        |> sync_lists()

      {:error, _changeset} -> {:noreply, socket}
    end
  end

  def handle_event("toggle", %{"moderate" => _}, socket) do
    {:noreply, assign(socket, :moderate, !socket.assigns.moderate)}
  end

  def handle_event("activate", %{"character" => id}, socket) do
    case socket.assigns.character.user_id
      |> Accounts.get_user!()
      |> Accounts.update_user(%{active_character_id: id})
    do
      {:ok, user} ->
        character = Accounts.get_character!(user.active_character_id)

        socket
        |> assign(:character, character)
        |> assign(:character_item_ids, Accounts.get_character_item_ids(character))
        |> assign(:character_mod_ids, Accounts.get_character_mod_ids(character))
        |> sync_lists()

      {:error, _reason} ->
        {:noreply, socket}
    end
  end

  def handle_event("activate", %{"mod" => id}, socket) do
    mod_ids = Accounts.activate_mod(socket.assigns.character, mod(socket, id))
    socket = assign(socket, :character_mod_ids, mod_ids)
    sync_lists(socket)
  end

  def handle_event("deactivate", %{"mod" => id}, socket) do
    mod_ids = Accounts.deactivate_mod(socket.assigns.character, mod(socket, id))
    socket = assign(socket, :character_mod_ids, mod_ids)
    sync_lists(socket)
  end

  def handle_event("add", %{"type" => type}, socket) do
    {:noreply, assign(socket, :changeset, Gallery.changeset(type))}
  end

  def handle_event("edit", %{"character" => id}, socket) do
    character = Enum.find(socket.assigns.characters, & &1.id == String.to_integer(id))
    {:noreply, assign(socket, :changeset, Accounts.change_character(character, %{}))}
  end

  def handle_event("edit", _params, socket) do
    struct = LotdWeb.GalleryView.filtered_struct(socket)

    changeset =
      cond do
        socket.assigns.filter_display -> Gallery.change_display(struct)
        socket.assigns.filter_room -> Gallery.change_room(struct)
        socket.assigns.filter_location -> Gallery.change_location(struct)
        socket.assigns.filter_region -> Gallery.change_region(struct)
        socket.assigns.filter_mod -> Gallery.change_mod(struct)
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

  def handle_event("insert", params, socket) do
    case params do
      %{"character" => params} ->
        params = Map.put(params, "user_id", socket.assigns.character.user_id)
        case Accounts.create_character(params) do
          {:ok, character} ->
            {:noreply, socket
            |> assign(:changeset, nil)
            |> assign(:characters, Accounts.list_characters(character.user_id))}

          {:error, changeset} ->
            {:noreply, assign(socket, :changeset, changeset)}
        end

      %{"mod" => params} ->
        case Gallery.create_mod(params) do
          {:ok, _mod} ->
            {:noreply, socket
            |> assign(:changeset, Gallery.change_mod(%Mod{}))
            |> assign(:mods, Gallery.list_mods())}

          {:error, changeset} ->
            {:noreply, assign(socket, :changeset, changeset)}
        end
    end
  end

  def handle_event("update", %{"mod" => params}, socket) do
    case Gallery.update_mod(socket.assigns.changeset.data, params) do
      {:ok, _mod} ->
        {:noreply, socket
        |> assign(:changeset, nil)
        |> assign(:mods, Gallery.list_mods())}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_event("update", %{"character" => params}, socket) do
    case Accounts.update_character(socket.assigns.changeset.data, params) do
      {:ok, character} ->
        {:noreply, socket
        |> assign(:changeset, nil)
        |> assign(:characters, Accounts.list_characters(character.user_id))}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_event("delete", _params, socket) do
    case socket.assigns.changeset.data do
      %Character{} = character ->
        case Accounts.delete_character(character) do
          {:ok, char} ->
            {:noreply, socket
            |> assign(:changeset, nil)
            |> assign(:characters, Enum.reject(socket.assigns.characters, & &1.id == char.id))}

          {:error, _reason} ->
            {:noreply, socket}
        end

      %Mod{} = mod ->
        case Gallery.delete_mod(mod) do
          {:ok, _mod} ->
            {:noreply, socket
            |> assign(:changeset, Gallery.change_mod(%Mod{}))
            |> assign(:character_mod_ids, Accounts.get_character_mod_ids(socket.assigns.character))
            |> assign(:filter_id, nil)
            |> assign(:mods, Gallery.list_mods())}

          {:error, _reason} ->
            {:noreply, socket}
        end
    end
  end

  defp mod(socket, id), do: Enum.find(socket.assigns.mods, & &1.id == String.to_integer(id))

  defp reset(socket) do
    socket
    |> assign(@filters)
    |> assign(search: "")
  end

  defp sync_lists(socket, return \\ :noreply) do
    struct = LotdWeb.GalleryView.filtered_struct(socket)

    search = socket.assigns.search
    region = socket.assigns.filter_region
    character_item_ids = socket.assigns.hide && socket.assigns.character_item_ids

    items =
      []
      |> Keyword.put(:search, search)
      |> Keyword.put(:hide, socket.assigns.hide)
      |> Keyword.put(:character_item_ids, socket.assigns.character_item_ids)
      |> Keyword.put(:character_mod_ids, socket.assigns.character_mod_ids)
      |> Keyword.put(:filter_id, struct && struct.id)
      |> Keyword.put(:filter_type, LotdWeb.GalleryView.filter?(socket))
      |> Keyword.put(:struct, LotdWeb.GalleryView.filtered_struct(socket))
      |> Gallery.list_items()


    {return, socket
    |> assign(:items, items)
    |> assign(:locations, Gallery.list_locations(search, region, character_item_ids))}
  end
end
