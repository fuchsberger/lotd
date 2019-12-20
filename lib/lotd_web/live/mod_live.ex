defmodule LotdWeb.ModLive do
  use LotdWeb, :live

  alias Lotd.{Accounts, Museum}

  def render(assigns), do: LotdWeb.ModView.render("index.html", assigns)

  def mount(session, socket) do

    sort = "name"
    dir = "asc"
    user = if session.user_id, do: Accounts.get_user!(session.user_id), else: nil

    socket = assign socket,
      mods: get_mods(sort, dir, user),
      search: "",
      sort: sort,
      dir: dir,
      user: user

    {:ok, socket}
  end

  def handle_event("toggle_active", %{"id" => id}, socket) do
    id = String.to_integer(id)
    character = socket.assigns.user.active_character
    mod = Enum.find(socket.assigns.mods, & &1.id == id)

    unless is_nil(Enum.find(character.mods, fn m -> m.id == id end)),
      do: Accounts.update_character_remove_mod(character, mod.id),
      else: Accounts.update_character_add_mod(character, mod)

    {:noreply, assign(socket, user: Accounts.get_user!(socket.assigns.user.id))}
  end

  def handle_info({:search, search_query}, socket) do
    socket = assign socket, search: search_query
    {:noreply, socket}
  end

  def handle_params(%{"sort" => sort, "dir" => dir}, _uri, socket) do
    case sort do
      sort when sort in ~w(name items) ->
        socket = assign socket,
          mods: get_mods(sort, dir, socket.assigns.user),
          sort: sort,
          dir: dir
        {:noreply, socket}
      _ ->
        {:noreply, socket}
    end
  end

  def handle_params(_params, _uri, socket), do: {:noreply, socket}

  defp get_mods(sort, dir, user) do
    if is_nil(user) do
      Museum.list_mods(sort, dir)
    else
      user_mods = Enum.map(user.active_character.mods, & &1.id)
      Museum.list_mods(sort, dir)
      |> Enum.map(& Map.put(&1, :active, Enum.member?(user_mods, &1.id)))
    end
  end
end
