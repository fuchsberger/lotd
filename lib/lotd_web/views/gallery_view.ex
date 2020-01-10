defmodule LotdWeb.GalleryView do
  use LotdWeb, :view

  def gallery_tab(active_room, room, title, class \\ "") do
    active = if active_room == room, do: " active", else: ""
    link_elm = live_link title,
      to: Routes.live_path(LotdWeb.Endpoint, LotdWeb.GalleryLive, room: room),
      class: "nav-link#{active}"

    content_tag :li, link_elm, class: "nav-item #{class}"
  end

  def display_class(current_display, nil) do
    base = "list-group-item list-group-item-action p-1 justify-content-between align-items-center"
    cond do
      is_nil(current_display) -> "#{base} d-flex active"
      true -> "#{base} d-flex"
    end
  end

  def display_class(current_display, display) do
    base = "list-group-item list-group-item-action p-1 justify-content-between align-items-center"
    cond do
      current_display == display.id -> "#{base} d-flex active"
      display.count == 0 -> "#{base} d-none"
      true -> "#{base} d-flex"
    end
  end

  def hidden?(item, display) do
    cond do
      not is_nil(display) && item.display_id != display -> "d-none"
      true -> "d-flex"
    end
  end
end
