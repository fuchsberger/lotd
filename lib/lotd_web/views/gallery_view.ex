defmodule LotdWeb.GalleryView do
  use LotdWeb, :view

  @base_class "list-group-item justify-content-between align-items-center p-1"

  def gallery_tab(active_room, room, title, class \\ "") do
    active = if active_room == room, do: " active", else: ""
    link_elm = live_link title,
      to: Routes.live_path(LotdWeb.Endpoint, LotdWeb.GalleryLive, room: room),
      class: "nav-link#{active}"

    content_tag :li, link_elm, class: "nav-item #{class}"
  end

  def display_class(current_display, nil) do
    cond do
      is_nil(current_display) ->
        "#{@base_class} list-group-item-action d-flex list-group-item-secondary"
      true ->
        "#{@base_class} list-group-item-action d-flex"
    end
  end

  def display_class(current_display, display) do
    cond do
      current_display == display.id ->
        "#{@base_class} list-group-item-action d-flex list-group-item-secondary"
      display.count == 0 ->
        "#{@base_class} list-group-item-action d-none"
      true ->
        "#{@base_class} list-group-item-action d-flex"
    end
  end

  def item_class(item, display, user, hide_collected) do
    cond do
      # hide items that are not in current display
      not is_nil(display) && item.display_id != display ->
        "#{@base_class} d-none"
      # if hide_collected == true and item was collected, then hide it
      hide_collected && user && Enum.find(user.active_character.items, & &1.id == item.id) ->
        "#{@base_class} d-none"
      # otherwise show items
      true ->
        "#{@base_class} d-flex"
    end
  end

  def collected?(item, user) do
    item_ids = Enum.map(user.active_character.items, & &1.id)
    if Enum.member?(item_ids, item.id), do: "icon-active", else: "icon-inactive"
  end

  def active?(boolean), do: if boolean, do: "icon-active", else: "icon-inactive"

  def hide_collected_legend(hide_collected) do
    if hide_collected, do: "number of items still to collect", else: "number of items in display"
  end
end
