defmodule LotdWeb.ItemComponent do
  use Phoenix.LiveComponent

  alias Lotd.{Accounts, Museum}
  alias Lotd.Accounts.Character
  alias Lotd.Museum.{Display, Item, Location, Mod, Quest}
  alias Lotd.Repo
  import Ecto.Query

  defp items_topic(socket), do: "items"

  def preload(list_of_assigns) do
    list_of_ids = Enum.map(list_of_assigns, & &1.id)

    characters_query = from(c in Character, select: c.id)
    display_query = from(d in Display, select: d.name)
    location_query = from(l in Location, select: l.name)
    mod_query = from(m in Mod, select: m.name)
    quest_query = from(q in Quest, select: q.name)

    items =
      from(i in Item,
        select: {i.id, i},
        preload: [
          characters: ^characters_query,
          display: ^display_query,
          location: ^location_query,
          mod: ^mod_query,
          quest: ^quest_query
        ],
        where: i.id in ^list_of_ids)
      |> Repo.all()
      |> Map.new()

    Enum.map(list_of_assigns, fn assigns ->
      Map.put(assigns, :item, items[assigns.id])
    end)
  end

  def update(assigns, socket) do
    item = Map.put(assigns.item, :found, Enum.member?(assigns.item.characters, assigns.character.id))
    {:ok, assign(socket, character: assigns.character, item: item)}
  end

  def render(assigns) do
    Phoenix.View.render(LotdWeb.ItemView, "item.html", assigns)
  end

  def handle_event("toggle_collect", _params, socket) do
    item = socket.assigns.item

    if item.found,
      do: Accounts.update_character_remove_item(socket.assigns.character, item.id),
      else: Accounts.update_character_collect_item(socket.assigns.character, item)

    send self(), {:updated_item, item}
    {:noreply, socket}
  end
end
