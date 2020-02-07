defmodule LotdWeb.ItemsLive do
  use Phoenix.LiveView, container: {:div, class: "container pt-2"}

  alias Lotd.{Accounts, Gallery}

  @defaults [
    character_id: nil,
    character_items: nil,
    # changeset: nil,
    # display_filter: nil,
    # hide: false,
    # location_filter: nil,
    moderate: false,
    moderator: false,
    # mod_filter: nil,
    # room_filter: nil,
    # search: "",
    # user: nil
  ]

  def render(assigns), do: LotdWeb.ItemView.render("index.html", assigns)

  def mount(_params, %{"user_id" => user_id }, socket) do
    user = Accounts.get_user!(user_id)

    items = Gallery.list_items(user.active_character)

    assigns = [
      character_id: user.active_character.id,
      character_items: user.active_character.items,
      items: items,
      moderator: user.moderator
    ]

    {:ok, assign(socket, Keyword.merge(@defaults, assigns))}
  end

  def mount(_params, _session, socket) do
    items = Gallery.list_items()

    assigns = [
      items: items,
    ]

    {:ok, assign(socket, Keyword.merge(@defaults, assigns))}
  end

  def handle_event("toggle", %{"field" => field}, socket) do
    field = String.to_atom(field)
    {:noreply, assign(socket, field, !Map.get(socket.assigns, field))}
  end

  def handle_event("toggle", %{"item" => id}, socket) do
    id = String.to_integer(id)
    character = Accounts.get_character!(socket.assigns.character_id)
    item = Enum.find(socket.assigns.items, & &1.id == id)

    case Enum.find(character.items, & &1.id == id) do
      nil ->
        Accounts.collect_item(character, item)
        {:noreply, assign(socket, character_items: [id | socket.assigns.character_items])}

      item ->
        Accounts.remove_item(character, item)
        items = List.delete(socket.assigns.character_items, id)
        {:noreply, assign(socket, character_items: items)}
    end
  end
end
