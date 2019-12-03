defmodule LotdWeb.ItemLive do

  use LotdWeb, :live

  alias Lotd.{Accounts, Museum}
  alias Lotd.Museum.{Item, Display, Location, Mod, Quest}

  alias LotdWeb.ItemView

  def render(assigns), do: ItemView.render("index.html", assigns)

  def mount(session, socket) do

    # as neither the user or character is changed during the items view we can attach the entire structure once without having to query again and again.
    if session.user_id do
      socket = assign socket, user: Accounts.get_user!(session.user_id)
      {:ok, fetch(socket)}
    else
      {:ok, fetch(socket)}
    end
  end

  def handle_event("validate", %{"item" => params}, socket) do
    changeset =
      %Item{}
      |> Museum.change_item(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("add", %{"item" => item }, socket) do
    case Museum.create_item(item) do
      {:ok, _item} ->
        # item = Phoenix.View.render_one(item, DataView, "item.json")
        # Endpoint.broadcast("public", "add-item", item)
        # {:reply, :ok, socket}

        {:noreply, fetch(socket)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end


  defp fetch(socket) do

    # get map data for secondary information
    locations= Museum.list_options(Location)
    quests = Museum.list_options(Quest)
    mods = Museum.list_options(Mod)
    displays = Museum.list_options(Display)

    items = Museum.list_items()
    |> Enum.map(fn item -> Map.put(item, :location, Map.get(locations, item.location_id)) end)
    |> Enum.map(fn item -> Map.put(item, :quest, Map.get(quests, item.quest_id)) end)
    |> Enum.map(fn item -> Map.put(item, :display, Map.get(displays, item.display_id)) end)
    |> Enum.map(fn item -> Map.put(item, :mod, Map.get(mods, item.mod_id)) end)

    items = if authenticated?(socket) do
      ids =
        socket.assigns.user.active_character
        |> Accounts.get_character_items()
        |> Enum.map(fn item -> item.id end)
      Enum.map(items, fn item -> Map.put(item, :found, Enum.member?(ids, item.id)) end)
    else
      items
    end

    assign socket,
      changeset: Museum.change_item(%Item{}),
      items: items,
      location_options: reverse_map(locations),
      quest_options: reverse_map(quests),
      mod_options: reverse_map(mods),
      display_options: reverse_map(displays)
  end

  defp reverse_map(map), do: Enum.into(map, %{}, fn {k, v} -> {v, k} end)
end
