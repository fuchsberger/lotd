defmodule LotdWeb.ItemLive do

  use LotdWeb, :live

  alias Lotd.{Accounts, Museum}
  alias LotdWeb.ItemView

  def render(assigns), do: ItemView.render("index.html", assigns)

  def mount(session, socket) do
    search = ""
    sort = "name"
    dir = "asc"
    user = if session.user_id, do: Accounts.get_user!(session.user_id), else: nil

    socket = assign socket,
      data: Museum.list_items(sort, dir, search, user),
      search: search,
      sort: sort,
      dir: dir,
      user: user

    {:ok, socket}
  end

  def handle_event("load_more", _params, socket) do
    data = Museum.list_items(
      socket.assigns.sort,
      socket.assigns.dir,
      socket.assigns.search,
      socket.assigns.user,
      socket.assigns.data.page_number + 1
    )

    {:noreply, assign(socket, data: Map.put(data, :entries, socket.assigns.data.entries ++ data.entries))}
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
    data = Museum.list_items(socket.assigns.sort, socket.assigns.dir, search, socket.assigns.user)
    {:noreply, assign(socket, data: data, search: search)}
  end

  def handle_params(%{"sort" => sort, "dir" => _dir}, _uri, socket) do
    case sort do
      sort when sort in ~w(name display room) ->
        dir = if sort == socket.assigns.sort do
          case socket.assigns.dir do
            "asc" -> "desc"
            "desc" -> "asc"
          end
        else
          "asc"
        end

        socket = assign socket,
          data: Museum.list_items(sort, dir, socket.assigns.search, socket.assigns.user),
          sort: sort,
          dir: dir
        {:noreply, socket}
      _ ->
        {:noreply, socket}
    end
  end

  def handle_params(_params, _uri, socket), do: {:noreply, socket}
end
