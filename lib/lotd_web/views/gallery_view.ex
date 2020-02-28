defmodule LotdWeb.GalleryView do
  use LotdWeb, :view

  import Ecto.Changeset, only: [ get_change: 2 ]

  def active(boolean), do: if boolean, do: " list-group-item-info"

  def add_link(type), do: content_tag(:button, "Add #{String.capitalize(type)}",
    class: "dropdown-item", type: "button", phx_click: "add", phx_value_type: type)

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

  def filter_class(id) do
    if is_nil(id), do: "btn-outline-secondary", else: "btn-secondary"
  end

  def header_room(rooms, displays, filter, id) do
    case {filter, id} do
      {_, nil} -> "Room"
      {"room", id} -> Enum.find(rooms, & &1.id == id) |> Map.get(:name)
      {"display", id} -> Enum.find(displays, & &1.id == id).room.name
      {_, _} -> "Room"
    end
  end

  def header_display(displays, filter, id) do
    case {filter, id} do
      {_, nil} -> "Display"
      {"display", id} -> Enum.find(displays, & &1.id == id) |> Map.get(:name)
      {_, _} -> "Display"
    end
  end


  def filter_text_class(id) do
    unless is_nil(id), do: "text-primary"
  end

  def filter_title(collection, id) do
    if is_nil(id) do
      "Filter: <span class='font-italic text-info'>none selected</span>"
    else
      case Enum.find(collection, & &1.id == id) do
        nil -> "Filter: <span class='font-italic text-danger'>invalid</span>"
        entry -> "Filter: <span class='font-italic text-warning'>#{entry.name}</span>"
      end
    end
  end

  def room_items(items, displays, room_id) do
    display_ids = displays |> Enum.filter(& &1.room_id == room_id) |> Enum.map(& &1.id)
    Enum.filter(items, & Enum.member?(display_ids, &1.display_id))
  end

  def room_options, do: [
    "Other": 0,
    "Hall of Heroes": 1,
    "Armory": 2,
    "Library": 3,
    "East Exhibit Halls": 4,
    "Dragonborn Hall": 5,
    "Natural Science": 6
  ]

  def tab(name, content, current_tab) do
    link = if name == current_tab,
      do: content_tag(:a, content, class: "nav-link px-2 active disabled"),
      else: content_tag(:a, content, class: "nav-link px-2", phx_click: "switch-tab", phx_value_tab: name)

    content_tag :li, link, class: "nav-item"
  end

  def title(struct), do: struct_to_string(struct) |> String.capitalize()

  def visible_displays(displays, filter, id) do
    case {filter, id} do
      {_, nil} -> displays
      {"room", id} -> Enum.filter(displays, & &1.room_id == id)
      {_, id} -> displays
    end
  end

  def visible_items(items, character_items, displays, filter_type, filter_val, hide, search) do
    items =
      cond do
        search != "" ->
          search = String.downcase(search)
          Enum.filter(items, & String.contains?(String.downcase(&1.name), search))

        is_nil(filter_val) ->
          items

        filter_type == "room" ->
          display_ids =
            displays
            |> Enum.filter(& &1.room_id == filter_val)
            |> Enum.map(& &1.id)

          Enum.filter(items, & Enum.member?(display_ids, &1.display_id))

        filter_type == "display" ->
          Enum.filter(items, & &1.display_id == filter_val)

        filter_type == "location" ->
          Enum.filter(items, & &1.location_id == filter_val)

        filter_type == "mod" ->
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
