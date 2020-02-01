defmodule LotdWeb.GalleryView do
  use LotdWeb, :view

  import Ecto.Changeset, only: [ get_change: 2 ]

  def active(boolean), do: if boolean, do: " list-group-item-info"

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

  def display_items(items, display_id), do: Enum.filter(items, & &1.display_id == display_id)
  def location_items(items, location_id), do: Enum.filter(items, & &1.location_id == location_id)
  def mod_items(items, mod_id), do: Enum.filter(items, & &1.mod_id == mod_id)
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
    if is_nil(room_filter), do: displays, else: Enum.filter(displays, & &1.room_id == room_filter)
  end

  def visible_items(items, displays, display_filter, _locations, location_filter, mods, mod_filter, room_filter, user, hide, search) do
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

    mod_ids = if is_nil(mod_filter),
      do: Enum.map(mods, & &1.id), else: [ mod_filter ]

    search = String.downcase(search)

    items =
      items
      |> Enum.filter(& Enum.member?(display_ids, &1.display_id))
      |> Enum.filter(& Enum.member?(mod_ids, &1.mod_id))
      |> Enum.filter(& String.contains?(String.downcase(&1.name), search))

    items = if location_filter,
      do: Enum.filter(items, & &1.location_id == location_filter),
      else: items

    if hide do
      user_item_ids = Enum.map(user.active_character.items, & &1.id)

      items
      |> Enum.filter(& not Enum.member?(user_item_ids, &1.id))
      |> Enum.take(200)
    else
      Enum.take(items, 200)
    end
  end

  def visible_mods(mods, user, moderate) do
    if is_nil(user) or moderate,
      do: mods,
      else: Enum.filter(mods, & Enum.member?(user.active_character.mods, &1.id))
  end
end
