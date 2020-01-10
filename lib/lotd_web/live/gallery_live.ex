defmodule LotdWeb.GalleryLive do

  use Phoenix.LiveView, container: {:div, class: "container h-100"}
  alias Lotd.{Accounts, Gallery}

  # import LotdWeb.LiveHelpers
  # import LotdWeb.ViewHelpers, only: [ authenticated?: 1, admin?: 1, moderator?: 1 ]

  def render(assigns), do: LotdWeb.GalleryView.render("index.html", assigns)

  def mount(params, socket) do
    user_id = Map.get(params, "user_id")
    user = unless is_nil(user_id), do: Accounts.get_user!(user_id), else: nil

    {:ok, assign(socket,
      authenticated?: not is_nil(user),
      displays: Gallery.list_displays(),
      hide_collected: true,
      user: user
    )}
  end

  def handle_params(%{"room" => room}, _uri, socket) do
    room = if room == "", do: nil, else: String.to_integer(room)

    # get all items for that room
    items = Gallery.list_items(room)

    # update displays with the proper item numbers
    displays = Enum.map(socket.assigns.displays, fn d ->
      item_ids = Enum.filter(items, fn i -> i.display_id == d.id end)

      Map.put(d, :count, Enum.count(item_ids))
    end)

    {:noreply, assign(socket, display: nil, displays: displays, items: items, room: room )}
  end

  def handle_params(_params, uri, socket) do
    if Map.has_key?(socket.assigns, :room),
      do: {:noreply, socket},
      else: handle_params(%{"room" => "1"}, uri, socket)
  end

  def handle_event("show-display", params, socket) do
    id = if Map.has_key?(params, "id"), do: String.to_integer(params["id"]), else: nil
    {:noreply, assign(socket, display: id)}
  end

  def handle_event("toggle-hide-collected", _params, socket) do
    {:noreply, assign(socket, :hide_collected, !socket.assigns.hide_collected)}
  end

  def handle_event("toggle-item", %{"id" => id}, socket) do
    user = socket.assigns.user
    character = user.active_character

    case Enum.find(socket.assigns.items, & &1.id == String.to_integer(id)) do
      nil ->
        # TODO: Flash an error
        {:noreply, socket}
      item ->
        item_ids = Enum.map(character.items, & &1.id)

        if Enum.member?(item_ids, item.id) do
          # add item to character
          character = Accounts.remove_item(character, item)
          {:noreply, assign(socket, :user, Map.put(user, :active_character, character))}
        else
          # remove item from character
          character =  Accounts.collect_item(character, item)
          {:noreply, assign(socket, :user, Map.put(user, :active_character, character))}
        end
    end
  end
end
