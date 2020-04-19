defmodule LotdWeb.GalleryLive do

  use Phoenix.LiveView, container: {:div, class: "container"}

  alias Lotd.{Accounts, Gallery}
  alias Lotd.Accounts.Character
  alias Lotd.Gallery.{Room, Region, Display, Location, Mod}
  alias LotdWeb.EntryView

  def render(assigns), do: LotdWeb.GalleryView.render("index.html", assigns)

  def mount(_params, session, socket) do
    user_id = Map.get(session, "user_id")
    user = if user_id, do: Accounts.get_user!(user_id), else: nil
    character = user && user.active_character

    socket
    |> assign(:admin?, user && user.admin)
    |> assign(:character, character)
    |> assign(:character_id, (if user, do: user.active_character_id, else: nil))
    |> assign(:character_item_ids, user && Accounts.get_character_item_ids(character))
    |> assign(:character_mod_ids, user && Accounts.get_character_mod_ids(character))
    |> assign(:changeset, nil)
    |> assign(:filter, nil)
    |> assign(:hide?, user && user.hide)
    |> assign(:moderate, false)
    |> assign(:moderator, user && user.moderator)
    |> assign(:searching?, false)
    |> assign(:search, "")
    |> assign(:tab, 3)
    |> assign(:user, user)
    |> sync_lists(:ok)
  end

  def handle_event("clear", %{"search" => _}, socket) do
    socket
    |> assign(:search, "")
    |> sync_lists()
  end

  def handle_event("clear", _params, socket) do
    case socket.assigns.filter do
      %Location{} -> assign(socket, :filter, Gallery.get_region!(socket.assigns.filter.region_id))
      %Display{} -> assign(socket, :filter, Gallery.get_room!(socket.assigns.filter.room_id))
      _ -> assign(socket, :filter, nil)
    end
    |> sync_lists()
  end

  def handle_event("filter", params, socket) do
    filter =
      case params do
        %{"display" => id} -> Gallery.get_display!(id)
        %{"room" => id} -> Gallery.get_room!(id)
        %{"location" => id} -> Gallery.get_location!(id)
        %{"region" => id} -> Gallery.get_region!(id)
        %{"mod" => id} -> Gallery.get_mod!(id)
      end

    socket
    |> assign(:filter, filter)
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
    case Accounts.update_user(user, %{hide: !socket.assigns.hide?}) do
      {:ok, user} ->
        socket
        |> assign(:hide?, user.hide)
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
    mod = Gallery.get_mod!(id)
    mod_ids = Accounts.activate_mod(socket.assigns.character, mod)

    socket
    |> assign(:filter, mod)
    |> assign(:character_mod_ids, mod_ids)
    |> sync_lists()
  end

  def handle_event("deactivate", %{"mod" => id}, socket) do
    mod = Gallery.get_mod!(id)
    mod_ids = Accounts.deactivate_mod(socket.assigns.character, mod)

    socket
    |> assign(:filter, mod)
    |> assign(:character_mod_ids, mod_ids)
    |> sync_lists()
  end

  def handle_event("add", %{"type" => type}, socket) do
    {:noreply, assign(socket, :changeset, Gallery.changeset(type))}
  end

  def handle_event("edit", %{"character" => id}, socket) do
    if Enum.member?(Enum.map(socket.assigns.characters, & &1.id), String.to_integer(id)) do
      changeset = id |> Accounts.get_character!() |> Accounts.change_character()
      {:noreply, assign(socket, :changeset, changeset)}
    else
      # this was a hacking attempt to change someone else's character
      {:noreply, socket}
    end
  end

  def handle_event("edit", _params, socket) do
    struct = socket.assigns.filter

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
        case Map.put(params, "user_id", socket.assigns.user.id) |> Accounts.create_character() do
          {:ok, character} ->
            socket
            |> assign(:changeset, nil)
            |> sync_lists()

          {:error, changeset} ->
            {:noreply, assign(socket, :changeset, changeset)}
        end

      %{"mod" => params} ->
        case Gallery.create_mod(params) do
          {:ok, _mod} ->
            socket
            |> assign(:changeset, Gallery.change_mod(%Mod{}))
            |> sync_lists()

          {:error, changeset} ->
            {:noreply, assign(socket, :changeset, changeset)}
        end
    end
  end

  def handle_event("update", %{"mod" => params}, socket) do
    case Gallery.update_mod(socket.assigns.changeset.data, params) do
      {:ok, _mod} ->
        socket
        |> assign(:changeset, nil)
        |> sync_lists()

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_event("rename", %{"character" => params}, socket) do
    case Accounts.update_character(socket.assigns.changeset.data, params) do
      {:ok, _character} ->
        socket
        |> assign(:changeset, nil)
        |> sync_lists()

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_event("delete", %{"character" => id}, socket) do
    case Accounts.get_character!(id) |> Accounts.delete_character() do
      {:ok, _character} ->
        socket
        |> assign(:changeset, nil)
        |> sync_lists()

      {:error, _reason} ->
        {:noreply, socket}
    end
  end

  def handle_event("delete", _params, socket) do
    case socket.assigns.changeset.data do
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

  defp sync_lists(socket, return \\ :noreply) do
    {return, socket
    |> assign(:items, Gallery.list_items(
        socket.assigns.search,
        socket.assigns.filter,
        socket.assigns.character_mod_ids,
        socket.assigns.hide? && socket.assigns.character_item_ids
      ))
    |> sync_locations()
    |> sync_mods()
    |> sync_characters()}
  end

  defp sync_locations(socket) do
    if socket.assigns.tab == 2 || String.length(socket.assigns.search) > 2 do
      socket
      |> assign(:regions, Gallery.list_regions(socket.assigns.search))
      |> assign(:locations, Gallery.list_locations(
          socket.assigns.search,
          socket.assigns.filter,
          socket.assigns.hide? && socket.assigns.character_item_ids
        ))
    else
      socket
    end
  end

  defp sync_characters(%{assigns: %{tab: tab, character_id: id}} = socket)
    when not tab == 3 or is_nil(id), do: socket

  defp sync_characters(%{assigns: %{character_id: id}} = socket) do
    characters =
      socket.assigns.user
      |> Accounts.list_characters()
      |> Phoenix.View.render_many(EntryView, "character.json", active: id)

    assign(socket, :characters, characters)
  end

  defp sync_mods(%{assigns: %{tab: tab, searching?: searching?}} = socket)
    when not tab == 2 or searching?, do: socket

  defp sync_mods(%{assigns: %{
    character_item_ids: item_ids,
    character_mod_ids: mod_ids,
    hide?: hide?,
    searching?: searching?,
    search: search}} = socket)
  do

    mods = case {hide?, searching?} do
      {true, true} -> Gallery.list_mods(item_ids, search)
      {true, false} -> Gallery.list_mods(item_ids)
      {false, true} -> Gallery.list_mods(search)
      {false, false} -> Gallery.list_mods()
    end

    if socket.assigns.character_id do
      %{true: active, false: inactive} = Enum.group_by(mods, & Enum.member?(mod_ids, &1.id) && &1.item_count > 0)

      socket
      |> assign(:active_mods, active)
      |> assign(:mods, inactive)
    else
      assign(socket, :mods, mods)
    end
  end
end
