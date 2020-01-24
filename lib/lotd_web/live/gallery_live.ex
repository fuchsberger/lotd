defmodule LotdWeb.GalleryLive do

  use Phoenix.LiveView, container: {:div, class: "container h-100"}
  alias Lotd.{Repo, Accounts, Gallery}

  def render(assigns), do: LotdWeb.GalleryView.render("index.html", assigns)

  def mount(params, socket) do
    user_id = Map.get(params, "user_id")
    user = unless is_nil(user_id), do: Accounts.get_user!(user_id), else: nil

    {:ok, assign(socket,
      changeset: nil,
      display: nil,
      hide_collected: not is_nil(user),
      items: Gallery.list_items(user),
      moderate: true,
      search: "",
      user: user,
      visible_items: []
    )}
  end

  def handle_params(%{"room" => room}, _uri, socket) do
    socket = assign socket,
      display: nil,
      search: "",
      room: if room == "", do: nil, else: String.to_integer(room)

    {:noreply, assign(socket, visible_items: get_visible_items(socket))}
  end

  def handle_params(_params, uri, socket) do
    if Map.has_key?(socket.assigns, :room),
      do: {:noreply, socket},
      else: handle_params(%{"room" => "1"}, uri, socket)
  end

  def handle_event("search", %{"search_field" => %{"query" => query}}, socket) do
    socket = assign socket, :search, query
    {:noreply, assign(socket, visible_items: get_visible_items(socket))}
  end

  def handle_event("show-display", params, socket) do
    id = if Map.has_key?(params, "id"), do: String.to_integer(params["id"]), else: nil
    socket = assign(socket, :display, id)
    {:noreply, assign(socket, visible_items: get_visible_items(socket))}
  end

  def handle_event("toggle-hide-collected", _params, socket) do
    socket = assign(socket, :hide_collected, !socket.assigns.hide_collected)
    {:noreply, assign(socket, :visible_items, get_visible_items(socket))}
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
        {:noreply, assign(socket, :visible_items, get_visible_items(socket))}
    end
  end

  defp get_visible_items(socket) do
    # first get all items filtered based on either search or room
    items =
      if socket.assigns.search != "" do
        search = String.downcase(socket.assigns.search)
        Enum.filter(socket.assigns.items, & String.contains?(String.downcase(&1.name), search))
      else
        Enum.filter(socket.assigns.items, & &1.room == socket.assigns.room)
      end

    # then filter items by display if one is selected
    items = if socket.assigns.display,
      do: Enum.filter(items, & &1.display_id == socket.assigns.display),
      else: items

    # if authenticated, attach collected (boolean) and remove collected (if enabled)
    unless is_nil(socket.assigns.user) do
      item_ids = Enum.map(socket.assigns.user.active_character.items, & &1.id)
      items = Enum.map(items, & Map.put(&1, :collected, Enum.member?(item_ids, &1.id)))
      if socket.assigns.hide_collected, do: Enum.reject(items, & &1.collected), else: items
    else
      items
    end
  end

  # MODERATION
  def handle_event("toggle-moderate", _params, socket) do
    {:noreply, assign(socket, :moderate, !socket.assigns.moderate)}
  end

  def handle_event("cancel-edit", _params, socket) do
    {:noreply, assign(socket, :changeset, nil)}
  end

  def handle_event("edit-item", %{"id" => id}, socket) do
    changeset = Gallery.change_item(Gallery.get_item!(id), %{})
    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("validate", %{"item" => params}, socket) do
    changeset =
      socket.assigns.changeset.data
      |> Gallery.change_item(params)
      |> Map.put(:action, :update)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"item" => item_params}, socket) do
    case Gallery.update_item(socket.assigns.changeset.data, item_params) do
      {:ok, item } ->
        item = Repo.preload item, :display
        index = Enum.find_index(socket.assigns.items, & &1.id == item.id)
        socket = assign(socket, :items, List.replace_at(socket.assigns.items, index, item))

        {:noreply, assign(socket, changeset: nil, visible_items: get_visible_items(socket))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
