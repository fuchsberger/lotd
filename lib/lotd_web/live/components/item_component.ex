defmodule LotdWeb.ItemComponent do
  use Phoenix.LiveComponent

  import Ecto.Query
  import Phoenix.HTML.Form, only: [checkbox: 3]
  import LotdWeb.ViewHelpers, only: [link_title: 1]

  alias Lotd.Accounts
  alias Lotd.Accounts.Character
  alias Lotd.Museum.{Display, Item, Location, Mod, Quest}
  alias Lotd.Repo

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
    found = cond do
      is_nil(assigns.character) -> false
      true -> Enum.member?(assigns.item.characters, assigns.character.id)
    end
    {:ok, assign(socket,
      character: assigns.character,
      item: Map.put(assigns.item, :found, found))
    }
  end

  def render(assigns) do
    ~L"""
      <tr phx-hook='Item'>
        <%= unless is_nil(@character) do %>
          <td class='text-center'>
            <%= checkbox :item, :found, [ phx_click: :toggle_collect, value: @item.found ] %>
          </td>
        <% end %>
        <td class='all font-weight-bold' data-sort='<%= @item.name %>'>
          <%= link_title(@item) %>
        </td>
        <td><a class='search-field'><%= @item.location %></a></td>
        <td><a class='search-field'><%= @item.quest %></a></td>
        <td><a class='search-field'><%= @item.display %></a></td>
        <td><a class='search-field'><%= @item.mod %></a></td>
      </tr>
    """
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
