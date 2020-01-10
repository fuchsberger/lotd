defmodule LotdWeb.GalleryLive do

  use Phoenix.LiveView, container: {:div, class: "container h-100"}
  alias Lotd.{Accounts, Gallery}

  # import LotdWeb.LiveHelpers
  # import LotdWeb.ViewHelpers, only: [ authenticated?: 1, admin?: 1, moderator?: 1 ]

  def render(assigns), do: LotdWeb.GalleryView.render("index.html", assigns)

  def mount(params, socket) do
    user = Accounts.get_user!(Map.get(params, "user_id"))
    {:ok, assign(socket, displays: Gallery.list_displays(), user: user )}
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

end
