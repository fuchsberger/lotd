defmodule LotdWeb.GalleryLive do

  use Phoenix.LiveView, container: {:div, class: "container-fluid"}

  alias Lotd.{Accounts, Gallery}
  alias Lotd.Gallery.{Room, Region, Display, Location, Mod}

  def render(assigns), do: LotdWeb.GalleryView.render("index.html", assigns)

  def mount(_params, session, socket) do
    user_id = Map.get(session, "user_id")
    user = if user_id, do: Accounts.get_user!(user_id), else: nil
    character = user && user.active_character

    items = if is_nil(user) || user.moderator || user.admin,
      do: Gallery.list_items(),
      else: Gallery.list_items(user)

    displays = Gallery.get_displays(items)
    rooms = Gallery.get_rooms(displays)
    locations = Gallery.get_locations(items)
    regions = Gallery.get_regions(locations)
    mods = Gallery.list_mods()

    {:ok, socket
    |> assign(:admin, user && user.admin)
    |> assign(:character, character)
    |> assign(:character_item_ids, user && Accounts.get_character_item_ids(character))
    |> assign(:character_mod_ids, user && Accounts.get_character_mod_ids(character))
    |> assign(:changeset, Gallery.changeset("mod"))
    |> assign(:filter_id, nil)
    |> assign(:filter_type, nil)
    |> assign(:items, items)
    |> assign(:displays, displays)
    |> assign(:rooms, rooms)
    |> assign(:locations, locations)
    |> assign(:regions, regions)
    |> assign(:search, "")
    |> assign(:tab, "mod")
    |> assign(:moderate, true)
    |> assign(:moderator, user && user.moderator)
    |> assign(:mods, mods)
    |> assign(:user, user)}
  end

  def handle_event("filter", %{"type" => type, "id" => id}, socket) do
    id = String.to_integer(id)
    {changeset, type, id} =
      if type == socket.assigns.filter_type && id == socket.assigns.filter_id,
        do: {Gallery.changeset(type), nil, nil},
        else: {Gallery.changeset(type, id), type, id}

    {:noreply, socket
    |> assign(changeset: changeset)
    |> assign(filter_id: id)
    |> assign(filter_type: type)
    |> assign(search: "")}
  end

  def handle_event("search", %{"search" => %{"query" => query}}, socket) do
    {:noreply, assign(socket, search: query)}
  end

  def handle_event("tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, :tab, tab)}
  end

  def handle_event("toggle", %{"type" => "moderate" = _type}, socket) do
    {:noreply, assign(socket, :moderate, !socket.assigns.moderate)}
  end

  def handle_event("clear", _params, socket), do: {:noreply, assign(socket, search: "")}


  def handle_event("update", %{"user" => %{"hide" => _hide} = params}, socket) do
    case Accounts.toggle_hide(socket.assigns.user, params) do
      {:ok, %{hide: hide}} ->
        {:noreply, assign(socket, :user, Map.put(socket.assigns.user, :hide, hide))}

      {:error, _changeset} ->
        {:noreply, socket}
    end
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

  def handle_event("validate", %{"mod" => params}, socket) do
    changeset = Gallery.change_mod(socket.assigns.changeset.data, params)
    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("insert", %{"mod" => params}, socket) do
    case Gallery.create_mod(params) do
      {:ok, _mod} ->
        {:noreply, socket
        |> assign(:changeset, Gallery.change_mod(%Mod{}))
        |> assign(:mods, Gallery.list_mods())}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_event("update", %{"mod" => params}, socket) do
    case Gallery.update_mod(socket.assigns.changeset.data, params) do
      {:ok, _mod} ->
        {:noreply, socket
        |> assign(:changeset, Gallery.change_mod(%Mod{}))
        |> assign(:mods, Gallery.list_mods())}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_event("delete", %{"type" => "Mod" = _type, "id" => id}, socket) do
    mod = Enum.find(socket.assigns.mods, & &1.id == String.to_integer(id))

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
