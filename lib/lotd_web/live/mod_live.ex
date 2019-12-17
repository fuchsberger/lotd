defmodule LotdWeb.ModLive do
  use LotdWeb, :live

  alias Lotd.{Accounts, Museum}

  def render(assigns), do: LotdWeb.ModView.render("index.html", assigns)

  def mount(session, socket) do
    user = if session.user_id, do: Accounts.get_user!(session.user_id), else: nil

    socket = assign socket,
      mods: sort(Museum.list_mods(), "items"),
      search: "",
      sort: "items",
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

  def handle_params(%{"sort_by" => sort_by}, _uri, socket) do
    case sort_by do
      sort_by when sort_by in ~w(name items) ->
        socket = assign socket,
          mods: sort(socket.assigns.mods, sort_by, sort_by == socket.assigns.sort),
          sort: sort_by
        {:noreply, filter(socket)}
      _ ->
        {:noreply, socket}
    end
  end

  def handle_params(_params, _uri, socket), do: {:noreply, socket}

  defp filter(socket) do
    filter = String.downcase(socket.assigns.search)
    visible_mods = Enum.filter(socket.assigns.mods,
      fn m -> String.contains?(String.downcase(m.name), filter) end)

    assign socket, visible_mods: visible_mods
  end
end
