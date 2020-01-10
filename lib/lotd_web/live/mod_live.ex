defmodule LotdWeb.ModLive do
  use Phoenix.LiveView, container: {:div, class: "container"}
  import LotdWeb.LiveHelpers
  import LotdWeb.ViewHelpers, only: [ authenticated?: 1, admin?: 1, moderator?: 1 ]

  alias Lotd.{Accounts, Gallery}

  def render(assigns), do: LotdWeb.ModView.render("index.html", assigns)

  def mount(session, socket) do

    sort = "items"
    dir = "asc"
    user = if session.user_id, do: Accounts.get_user!(session.user_id), else: nil

    socket = assign socket,
      mods: Gallery.list_mods(),
      search: "",
      sort: sort,
      dir: dir,
      user: user

    {:ok, filter(socket)}
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
    {:noreply, filter(socket)}
  end

  def handle_params(%{"sort" => sort, "dir" => _dir}, _uri, socket) do
    case sort do
      sort when sort in ~w(name items) ->
        dir = if sort == socket.assigns.sort do
          case socket.assigns.dir do
            "asc" -> "desc"
            "desc" -> "asc"
          end
        else
          case sort do
            "items" -> "desc"
            _ -> "asc"
          end
        end

        socket = assign socket,
          mods: sort(socket.assigns.mods, sort, dir),
          sort: sort,
          dir: dir

        {:noreply, filter(socket)}
      _ ->
        {:noreply, socket}
    end
  end

  def handle_params(_params, _uri, socket), do: {:noreply, socket}

  defp filter(socket) do
    filter = String.downcase(socket.assigns.search)
    assign(socket, mods: Enum.map(socket.assigns.mods, fn m ->
      Map.put(m, :visible, String.contains?(String.downcase(m.name), filter))
    end))
  end
end
