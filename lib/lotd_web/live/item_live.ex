defmodule LotdWeb.ItemLive do

  use LotdWeb, :live

  alias Lotd.{Accounts, Museum}
  alias LotdWeb.ItemView

  def render(assigns), do: ItemView.render("index.html", assigns)

  def mount(session, socket) do

    page = 1
    search = ""
    sort = "name"
    dir = "asc"
    user = if session.user_id, do: Accounts.get_user!(session.user_id), else: nil

    socket = assign socket,
      fully_loaded: false,
      items: get_items(page, sort, dir, search, user),
      item_count: Museum.item_count(user, search),
      page: page,
      search: search,
      sort: sort,
      dir: dir,
      user: user

    {:ok, socket}
  end

  def handle_event("load_more", params, socket) do
    page = socket.assigns.page + 1
    items = get_items(page, socket.assigns.sort, socket.assigns.dir, socket.assigns.search, socket.assigns.user)
    {:noreply, assign(socket, page: page, items: socket.assigns.items ++ items)}
  end

  def handle_event("toggle_collected", %{"id" => id}, socket) do
    character = socket.assigns.user.active_character
    item = Museum.get_item!(id)

    if Enum.member?(character.items, item),
      do: Accounts.update_character_remove_item(character, item.id),
      else: Accounts.update_character_collect_item(character, item)

    {:noreply, assign(socket, user: Accounts.get_user!(socket.assigns.user.id))}
  end

  def handle_info({:search, search}, socket) do
    page = 1
    items = get_items(page, socket.assigns.sort, socket.assigns.dir, search, socket.assigns.user)
    item_count = Museum.item_count(socket.assigns.user, search)
    {:noreply, assign(socket, items: items, item_count: item_count, search: search, page: page)}
  end

  def handle_params(%{"sort" => sort, "dir" => dir}, _uri, socket) do
    case sort do
      sort when sort in ~w(name display room) ->
        page = 1
        socket = assign socket,
          items: get_items(page, sort, dir, socket.assigns.search, socket.assigns.user),
          page: page,
          sort: sort,
          dir: dir
        {:noreply, socket}
      _ ->
        {:noreply, socket}
    end
  end

  def handle_params(_params, _uri, socket), do: {:noreply, socket}

  defp get_items(page, sort, dir, search, user) do
    if is_nil(user) do
      Museum.list_items(page, sort, dir, search)
    else
      user_items = Enum.map(user.active_character.items, & &1.id)
      Museum.list_items(page, sort, dir, search, user)
      |> Enum.map(& Map.put(&1, :active, Enum.member?(user_items, &1.id)))
    end
  end
end
