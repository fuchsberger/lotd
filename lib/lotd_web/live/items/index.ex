defmodule LotdWeb.ItemLive.Index do
  use LotdWeb, :live_view

  alias Lotd.{Accounts, Gallery, Skyrim}
  alias Lotd.Gallery.{Item, Display}
  alias Lotd.Skyrim.{Location, Mod, Quest}
  alias LotdWeb.ItemView

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
      |> Gallery.change_item(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("add", %{"item" => item }, socket) do
    case Gallery.create_item(item) do
      {:ok, _item} ->
        # item = Phoenix.View.render_one(item, DataView, "item.json")
        # Endpoint.broadcast("public", "add-item", item)
        # {:reply, :ok, socket}

        {:noreply, fetch(socket)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def render(assigns) do
    ItemView.render("index.html", assigns)
  end

  defp fetch(socket) do

    # get map data for secondary information
    locations= Skyrim.list_options(Location)
    quests = Skyrim.list_options(Quest)
    mods = Skyrim.list_options(Mod)
    displays = Skyrim.list_options(Display)

    items = Gallery.list_items()
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
      changeset: Gallery.change_item(%Item{}),
      items: items,
      location_options: locations,
      quest_options: quests,
      mod_options: mods,
      display_options: displays
  end
end
