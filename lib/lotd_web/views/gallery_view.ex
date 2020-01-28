defmodule LotdWeb.GalleryView do
  use LotdWeb, :view

  def active(boolean), do: if boolean, do: " active"

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

  def collected_count(user, items) do
    item_ids = Enum.map(user.active_character.items, & &1.id)

    items
    |> Enum.filter(& Enum.member?(user.active_character.mods, &1.mod_id))
    |> Enum.filter(& Enum.member?(item_ids, &1.id))
    |> Enum.count()
  end

  def collectable_count(user, items) do
    items
    |> Enum.filter(& Enum.member?(user.active_character.mods, &1.mod_id))
    |> Enum.count()
  end

  defp count_items(items, display_id),
    do: Enum.filter(items, & &1.display_id == display_id) |> Enum.count()

  def active?(boolean), do: if boolean, do: "icon-active", else: "icon-inactive"

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

  def visible_displays(displays, room_filter) do
    if is_nil(room_filter), do: displays, else: Enum.filter(displays, & &1.room_id == room_filter)
  end

  def visible_items(items, displays, display_filter, mods, mod_filter, room_filter) do
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

    mod_ids = if is_nil(mod_filter), do: Enum.map(mods, & &1.id), else: [ mod_filter ]

    items
    |> Enum.filter(& Enum.member?(display_ids, &1.display_id))
    |> Enum.filter(& Enum.member?(mod_ids, &1.mod_id))
    |> Enum.take(200)
  end
end
