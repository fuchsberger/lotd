defmodule LotdWeb.CharacterLive do
  use LotdWeb, :live

  alias Lotd.Accounts

  def render(assigns), do: LotdWeb.CharacterView.render("index.html", assigns)

  def mount(session, socket) do
    user = if session.user_id, do: Accounts.get_user!(session.user_id), else: nil

    socket = assign socket,
      characters: sort(Accounts.list_characters(user), "items"),
      search: "",
      sort: "items",
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

  def handle_params(%{"sort_by" => sort_by}, _uri, socket) do
    case sort_by do
      sort_by when sort_by in ~w(name items) ->
        socket = assign socket,
          characters: sort(socket.assigns.characters, sort_by, sort_by == socket.assigns.sort),
          sort: sort_by
        {:noreply, filter(socket)}
      _ ->
        {:noreply, socket}
    end
  end

  def handle_params(_params, _uri, socket), do: {:noreply, socket}

  defp filter(socket) do
    filter = String.downcase(socket.assigns.search)
    visible_characters = Enum.filter(socket.assigns.characters,
      fn c -> String.contains?(String.downcase(c.name), filter) end)

    assign socket, visible_characters: visible_characters
  end
end
