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
      hide_collected: not is_nil(user),
      user: user
    )}
  end

  def handle_params(%{"room" => room}, _uri, socket) do
    room = if room == "", do: nil, else: String.to_integer(room)

    # get all items for that room
    socket = assign(socket, display: nil, items: Gallery.list_items(room), room: room )

    # set visible displays and return socket
    {:noreply, assign(socket, :visible_displays, calculate_visible_displays(socket))}
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
    socket = assign(socket, :hide_collected,  !socket.assigns.hide_collected)
    {:noreply, assign(socket, :visible_displays, calculate_visible_displays(socket))}
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
          socket = assign(socket, :user, Map.put(user, :active_character, character))
          {:noreply, assign(socket, :visible_displays, calculate_visible_displays(socket))}
        else
          # remove item from character
          character =  Accounts.collect_item(character, item)
          socket = assign(socket, :user, Map.put(user, :active_character, character))
          {:noreply, assign(socket, :visible_displays, calculate_visible_displays(socket))}
        end
    end
  end

  defp calculate_visible_displays(socket) do

    Enum.map(socket.assigns.displays, fn d ->

      item_ids = socket.assigns.items
        |> Enum.filter(& &1.display_id == d.id)
        |> Enum.map(& &1.id)

      count = Enum.count(item_ids)

      if socket.assigns.hide_collected do
        user_item_ids = Enum.map(socket.assigns.user.active_character.items, & &1.id)
        intersection = user_item_ids -- item_ids
        intersection = user_item_ids -- intersection
        found = Enum.count(intersection)
        Map.put(d, :count, count - found)
      else
        Map.put(d, :count, count)
      end
    end)
    |> Enum.filter(& &1.count > 0)
  end
end
