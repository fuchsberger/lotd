defmodule LotdWeb.GalleryView do
  use LotdWeb, :view

  @base_class "list-group-item justify-content-between align-items-center p-1"

  def gallery_tab(active_room, search, room, title, class \\ "") do

    active = cond do
      search != "" -> ""
      active_room == room -> " active"
      true -> ""
    end

    link_elm = live_link title,
      to: Routes.live_path(LotdWeb.Endpoint, LotdWeb.GalleryLive, room: room),
      class: "nav-link#{active}"

    content_tag :li, link_elm, class: "nav-item #{class}"
  end

  def displays(items, room, search) do
    items =
      if search == "" do
        Enum.filter(items, & &1.room == room)
      else
        search = String.downcase(search)
        Enum.filter(items, & String.contains?(String.downcase(&1.name), search))
      end

    items
    |> Enum.map(& &1.display)
    |> Enum.uniq()
    |> Enum.map(& Map.put(&1, :count, count_items(items, &1.id)))
    |> Enum.sort(& &1.name <= &2.name)
  end

  defp count_items(items, display_id),
    do: Enum.filter(items, & &1.display_id == display_id) |> Enum.count()

  def display_class(current_display, nil) do
    cond do
      is_nil(current_display) ->
        "#{@base_class} list-group-item-action d-flex list-group-item-secondary"
      true ->
        "#{@base_class} list-group-item-action d-flex"
    end
  end

  def display_class(display, current_display) do
    if current_display == display.id,
      do: "#{@base_class} list-group-item-action d-flex list-group-item-secondary",
      else: "#{@base_class} list-group-item-action d-flex"
  end

  def active?(boolean), do: if boolean, do: "icon-active", else: "icon-inactive"

  def hide_collected_legend(hide_collected) do
    if hide_collected, do: "number of items still to collect", else: "number of items in display"
  end
end
