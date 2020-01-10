defmodule LotdWeb.CharacterLive do
  use Phoenix.LiveView, container: {:div, class: "container"}
  import LotdWeb.LiveHelpers
  import LotdWeb.ViewHelpers, only: [ authenticated?: 1, admin?: 1, moderator?: 1 ]

  alias Lotd.Accounts

  def render(assigns), do: LotdWeb.CharacterView.render("index.html", assigns)

  def mount(session, socket) do

    sort = "items"
    dir = "desc"
    user = if session.user_id, do: Accounts.get_user!(session.user_id), else: nil

    socket = assign socket,
      characters: Accounts.get_characters(user),
      search: "",
      sort: sort,
      dir: dir,
      user: user

    {:ok, filter(socket)}
  end

  def handle_event("activate", %{"id" => id}, socket) do
    case Accounts.get_character(id) do
      {:ok, character} ->
        if character.user_id == socket.assigns.user.id do # <-- hacker safety measure
          Accounts.activate_character(socket.assigns.user, character)
          {:noreply, assign(socket, user: Accounts.get_user!(socket.assigns.user.id))}
        else
          {:noreply, socket}
        end
      {:error, _reason} ->
        {:noreply, socket}
    end
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
          characters: sort(socket.assigns.characters, sort, dir),
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
    assign(socket, characters: Enum.map(socket.assigns.characters, fn c ->
      Map.put(c, :visible, String.contains?(String.downcase(c.name), filter))
    end))
  end
end
