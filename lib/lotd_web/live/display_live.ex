defmodule LotdWeb.DisplayLive do
  use LotdWeb, :live

  alias Lotd.{Accounts, Museum}

  def render(assigns), do: LotdWeb.DisplayView.render("index.html", assigns)

  def mount(session, socket) do
    user = if session.user_id, do: Accounts.get_user!(session.user_id), else: nil

    socket = assign socket,
      displays: Museum.list_displays(),
      search: "",
      sort: "name",
      user: user

    {:ok, filter(socket)}
  end

  def handle_info({:search, search_query}, socket) do
    socket = assign socket, search: search_query
    {:noreply, filter(socket)}
  end

  def handle_params(%{"sort" => sort, "dir" => dir}, _uri, socket) do
    case sort do
      sort when sort in ~w(name room items) ->
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
          displays: sort(socket.assigns.displays, sort, dir),
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
    assign(socket, displays: Enum.map(socket.assigns.displays, fn d ->
      Map.put(d, :visible, String.contains?(String.downcase(d.name), filter))
    end))
  end
end
