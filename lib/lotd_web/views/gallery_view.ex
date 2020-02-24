defmodule LotdWeb.GalleryView do
  use LotdWeb, :view

  import Ecto.Changeset, only: [ get_change: 2 ]

  def active(boolean), do: if boolean, do: " list-group-item-info"

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

  def item_icon(id, user_items, moderate) do
    cond do
      moderate ->
        icon("edit", class: "text-primary")

      is_list(user_items) ->
        active_class = if Enum.member?(user_items, id), do: "active", else: "inactive"
        icon("edit", class: "text-primary mr-1 icon-#{active_class}")

      true -> nil
    end
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

  def visible_displays(displays, room_filter) do
    if is_nil(room_filter),
      do: displays,
      else: Enum.filter(displays, & &1.room_id == room_filter)
  end

  def visible_items(items, character_items, displays, display_filter, location_filter, mod_filter, room_filter, hide, search) do
    display_ids = cond do
      not is_nil(display_filter) ->
        [ display_filter ]

      not is_nil(room_filter) ->
        displays
        |> Enum.filter(& &1.room_id == room_filter)
        |> Enum.map(& &1.id)

      true ->
        Enum.map(displays, & &1.id)
    end

    search = String.downcase(search)

    items =
      items
      |> Enum.filter(& Enum.member?(display_ids, &1.display_id))
      |> Enum.filter(& String.contains?(String.downcase(&1.name), search))

    items = if location_filter,
      do: Enum.filter(items, & &1.location_id == location_filter),
      else: items

    items = if mod_filter,
      do: Enum.filter(items, & &1.mod_id == mod_filter),
      else: items

    items = if hide,
      do: Enum.reject(items, & Enum.member?(character_items, &1.id)),
      else: items

    Enum.take(items, 200)
  end
end
