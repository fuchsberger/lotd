defmodule LotdWeb.ModLive do
  use LotdWeb, :live

  alias Lotd.{Accounts, Museum}
  alias Lotd.Museum.Mod

  def render(assigns), do: LotdWeb.ModView.render("index.html", assigns)

  def mount(session, socket) do

    user = if session.user_id, do: Accounts.get_user!(session.user_id), else: nil

    mods = unless is_nil(user) do
      character_mod_ids = Accounts.get_character_mod_ids(user.active_character)

      Museum.list_mods()
      |> Enum.map(fn mod -> Map.put(mod, :active, Enum.member?(character_mod_ids, mod.id)) end)
    else
      Museum.list_mods()
    end

    socket = assign socket,
      modal: %{
        changeset: Museum.change_mod(%Mod{}),
        error: nil,
        info: nil,
        options: %{ url: true },
        show: false,
        submitted: false
      },
      mods: mods,
      search: "",
      sort: nil,
      user: user

    {:ok, filter(socket)}
  end

  def handle_event("validate", %{"mod" => mod_params}, socket) do
    changeset =
      %Mod{}
      |> Museum.change_mod(mod_params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("add", %{"mod" => mod }, socket) do

    case Museum.create_item(mod) do
      {:ok, _mod} ->
        # item = Phoenix.View.render_one(item, DataView, "item.json")
        # Endpoint.broadcast("public", "add-item", item)
        # {:reply, :ok, socket}

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_params(%{"sort_by" => sort_by}, _uri, socket) do
    case sort_by do
      sort_by
      when sort_by in ~w(name filename display_count location_count quest_count) ->
        socket = assign(socket, mods: sort(socket.assigns.mods, sort_by, sort_by == socket.assigns.sort), sort: sort_by)
        {:noreply, filter(socket)}
      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("toggle_active", %{"id" => id}, socket) do
    character = socket.assigns.user.active_character
    mod = Enum.find(socket.assigns.mods, & &1.id == String.to_integer(id))

    if mod.active,
      do: Accounts.update_character_remove_mod(character, mod.id),
      else: Accounts.update_character_add_mod(character, mod)

    mod = Map.put(mod, :active, !mod.active)

    {:noreply, update_mod(socket, mod)}
  end

  def handle_params(_params, _uri, socket), do: {:noreply, socket}

  def handle_info({:search, search_query}, socket) do
    socket = assign socket, search: search_query
    {:noreply, filter(socket)}
  end

  def handle_info({:toggle_modal, _params}, socket) do
    {:noreply, assign(socket, show_modal: !socket.assigns.show_modal)}
  end

  def handle_info({Lotd, [:item, :saved], item}, socket) do
    item = if authenticated?(socket), do:
      Map.put(item, :found, Museum.item_owned?(item, socket.assigns.user.active_character_id)),
      else: item

    item = item
    |> Map.put(:location, Map.get(socket.assigns.locations, item.location_id))
    |> Map.put(:quest, Map.get(socket.assigns.quests, item.quest_id))
    |> Map.put(:mod, Map.get(socket.assigns.mods, item.mod_id))
    |> Map.put(:display, Map.get(socket.assigns.displays, item.display_id))

    # if element is already in list, replace it, otherwise add it
    items = socket.assigns.items
    if index = Enum.find_index(items, fn i -> i.id == item.id end) do
      # could also do: https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#send_update/2
      {:noreply, assign(socket, :items, List.replace_at(items, index, item))}
    else
      {:noreply, assign(socket, :items, [ item | items ])}
    end
  end

  defp filter(socket) do

    filter = String.downcase(socket.assigns.search)

    visible_mods = Enum.filter(socket.assigns.mods, fn m ->
      String.contains?(String.downcase(m.name), filter)
    end)

    assign(socket, visible_mods: visible_mods)
  end

  defp update_mod(socket, mod) do
    index = Enum.find_index(socket.assigns.mods, fn m -> m.id == mod.id end)
    mods = List.replace_at(socket.assigns.mods, index, mod)

    socket
    |> assign(:mods, mods)
    |> filter()
  end
end
