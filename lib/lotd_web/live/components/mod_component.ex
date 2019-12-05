defmodule LotdWeb.ModComponent do
  use Phoenix.LiveComponent

  import Ecto.Query
  import Phoenix.HTML.Form, only: [checkbox: 3]
  import LotdWeb.ViewHelpers, only: [link_title: 1]

  alias Lotd.{Accounts, Museum}
  alias Lotd.Accounts.Character
  alias Lotd.Museum.{Item, Location, Mod, Quest}
  alias Lotd.Repo

  defp items_topic(socket), do: "items"

  def preload(list_of_assigns) do
    list_of_ids = Enum.map(list_of_assigns, & &1.id)

    location_query = from(l in Location, select: l.id)
    quest_query = from(q in Quest, select: q.id)

    mods =
      from(m in Mod,
        select: {m.id, m},
        preload: [
          locations: ^location_query,
          quests: ^quest_query
        ],
        where: m.id in ^list_of_ids)
      # |> Repo.aggregate(:count, :locations)
      |> Repo.all()
      |> Map.new()

    Enum.map(list_of_assigns, fn assigns ->
      Map.put(assigns, :mod, mods[assigns.id])
    end)
  end

  def update(assigns, socket) do
    activated = cond do
      is_nil(assigns.character) -> false
      true -> Enum.member?(assigns.character_mods, assigns.mod.id)
    end
    {:ok, assign(socket,
      character: assigns.character,
      mod: Map.put(assigns.mod, :activated, activated))
    }
  end

  def render(assigns) do
    ~L"""
      <tr phx-hook='Mod'>
        <%= unless is_nil(@character) do %>
          <td class='text-center'>
            <%= checkbox :mod, :activated, [ phx_click: :toggle_active, value: @mod.activated ] %>
          </td>
        <% end %>
        <td class='all font-weight-bold' data-sort='<%= @mod.name %>'>
          <%= link_title(@mod) %>
        </td>
        <td><%= Enum.count(@mod.locations) %></td>
        <td><%= Enum.count(@mod.quests) %></td>
      </tr>
    """
  end

  def handle_event("toggle_active", _params, socket) do
    mod = socket.assigns.mod

    if mod.activated,
      do: Accounts.update_character_remove_mod(socket.assigns.character, mod.id),
      else: Accounts.update_character_add_mod(socket.assigns.character, mod)

    send self(), {:updated_mod, mod}
    {:noreply, socket}
  end
end
