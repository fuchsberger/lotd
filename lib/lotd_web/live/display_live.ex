defmodule LotdWeb.DisplayLive do
  use LotdWeb, :live

  alias Lotd.{Accounts, Museum}

  def render(assigns), do: LotdWeb.DisplayView.render("index.html", assigns)

  def mount(session, socket) do
    user = if session.user_id, do: Accounts.get_user!(session.user_id), else: nil

    socket = assign socket,
      displays: sort(Museum.list_displays(), "name"),
      search: "",
      sort: "name",
      user: user

    {:ok, filter(socket)}
  end

  def handle_info({:search, search_query}, socket) do
    socket = assign socket, search: search_query
    {:noreply, filter(socket)}
  end

  def handle_params(%{"sort_by" => sort_by}, _uri, socket) do
    case sort_by do
      sort_by when sort_by in ~w(name room items) ->
        socket = assign socket,
          displays: sort(socket.assigns.displays, sort_by, sort_by == socket.assigns.sort),
          sort: sort_by
        {:noreply, filter(socket)}
      _ ->
        {:noreply, socket}
    end
  end

  def handle_params(_params, _uri, socket), do: {:noreply, socket}

  defp filter(socket) do
    filter = String.downcase(socket.assigns.search)
    visible_displays = Enum.filter(socket.assigns.displays,
      fn d -> String.contains?(String.downcase(d.name), filter) end)

    assign socket, visible_displays: visible_displays
  end
end
