defmodule LotdWeb.GalleryView do
  use LotdWeb, :view

  import Ecto.Changeset, only: [ get_change: 2 ]

  def active(boolean), do: if boolean, do: " list-group-item-info"

  def active(col, filter, id, check) do
    if filter == col, do: id == check, else: false
  end

  def add_link(type), do: content_tag(:button, "Add #{String.capitalize(type)}",
    class: "dropdown-item",
    type: "button",
    phx_click: "add",
    phx_value_type: type
  )

  def count(field, id, items) do
    items
    |> Enum.filter(& Map.get(&1, field) == id)
    |> Enum.count()
  end

  def count(field, id, items, character_items) do
    items
    |> Enum.filter(& Map.get(&1, field) == id)
    |> Enum.filter(& Enum.member?(character_items, &1.id))
    |> Enum.count()
  end

  def collected_count(user, _items) do
    user.active_character.items
    |> Enum.filter(& Enum.member?(user.active_character.mods, &1.mod_id))
    |> Enum.count()
  end

  def collectable_count(user, items) do
    items
    |> Enum.filter(& Enum.member?(user.active_character.mods, &1.mod_id))
    |> Enum.count()
  end

  def display_options(changeset, displays) do
    room_id = get_change(changeset, :room_id)
    displays = if room_id,
      do: Enum.filter(displays, & &1.room_id == room_id),
      else: displays

    [{"Please select...", nil} | Enum.map(displays, &{&1.name, &1.id})]
  end

  def header_display(displays, filter, id) do
    case {filter, id} do
      {_, nil} -> "Display"
      {"display", id} -> Enum.find(displays, & &1.id == id) |> Map.get(:name)
      {_, _} -> "Display"
    end
  end

  defp crumb_link(title, filter, id) do
    link title, to: "#", phx_click: "filter", phx_value_type: filter, phx_value_id: id
  end

  defp crumb(content, active \\ false) do
    if active do
      content_tag(:li, content, class: "breadcrumb-item active", aria_current: "page")
    else
      content_tag(:li, content, class: "breadcrumb-item")
    end
  end

  def filter_text(filter, id, rooms, displays, regions, locations, mods) do
    case {filter, id} do
      {_, nil} -> nil
      {"room", id} -> Enum.find(rooms, & &1.id == id) |> Map.get(:name)
      {"display", id} -> Enum.find(displays, & &1.id == id) |> Map.get(:name)
      {"region", id} -> Enum.find(regions, & &1.id == id) |> Map.get(:name)
      {"location", id} -> Enum.find(locations, & &1.id == id) |> Map.get(:name)
      {"mod", id} -> Enum.find(mods, & &1.id == id) |> Map.get(:name)
      _ -> nil
    end
  end

  def filter_parent(filter, id, displays, locations) do
    case {filter, id} do
      {_, nil} -> nil
      {"display", id} -> Enum.find(displays, & &1.id == id) |> Map.get(:room)
      {"location", id} -> Enum.find(locations, & &1.id == id) |> Map.get(:region)
      _ -> nil
    end
  end

  def details_cell(nil, visibility),
    do: content_tag(:td, "", class: "d-none d-#{visibility}-table-cell small")

  def details_cell(object, visibility) do
    class = "d-none d-#{visibility}-table-cell small"

    if object.url do
      content_tag(:td, link(object.name, to: object.url, class: "text-dark", target: "_blank"), class: class)
    else
      content_tag(:td, content_tag(:span, object.name, class: "text-muted"), class: class)
    end
  end

  def room_items(items, displays, room_id) do
    display_ids = displays |> Enum.filter(& &1.room_id == room_id) |> Enum.map(& &1.id)
    Enum.filter(items, & Enum.member?(display_ids, &1.display_id))
  end

  def region_items(items, locations, region_id) do
    location_ids = locations |> Enum.filter(& &1.region_id == region_id) |> Enum.map(& &1.id)
    Enum.filter(items, & Enum.member?(location_ids, &1.location_id))
  end

  def tab(name, content, current_tab) do
    link = if name == current_tab,
      do: content_tag(:a, content, class: "nav-link px-2 active disabled"),
      else: content_tag(:a, content, class: "nav-link px-2", phx_click: "switch-tab", phx_value_tab: name)

    content_tag :li, link, class: "nav-item"
  end

  def visible_displays(displays, filter, id) do
    case {filter, id} do
      {_, nil} -> displays
      {"room", id} -> Enum.filter(displays, & &1.room_id == id)
      _ -> displays
    end
  end

  def visible_items(items, character_items, displays, locations, filter, filter_val, hide, search) do
    items =
      cond do
        search != "" ->
          search = String.downcase(search)
          Enum.filter(items, & String.contains?(String.downcase(&1.name), search))

        is_nil(filter_val) ->
          items

        filter == "room" ->
          display_ids =
            displays
            |> Enum.filter(& &1.room_id == filter_val)
            |> Enum.map(& &1.id)

          Enum.filter(items, & Enum.member?(display_ids, &1.display_id))

        filter == "display" ->
          Enum.filter(items, & &1.display_id == filter_val)

        filter == "region" ->
          location_ids =
            locations
            |> Enum.filter(& &1.region_id == filter_val)
            |> Enum.map(& &1.id)

          Enum.filter(items, & Enum.member?(location_ids, &1.location_id))

        filter == "location" ->
          Enum.filter(items, & &1.location_id == filter_val)

        filter == "mod" ->
          Enum.filter(items, & &1.mod_id == filter_val)
      end

    # if hide is on, remove collected items first
    items = if hide,
      do: Enum.reject(items, & Enum.member?(character_items, &1.id)),
      else: items

    # only show 200 items for performance reasons
    Enum.take(items, 200)
  end
end
