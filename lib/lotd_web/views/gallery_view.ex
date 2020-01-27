defmodule LotdWeb.GalleryView do
  use LotdWeb, :view

  alias Lotd.Gallery.{Display, Item, Mod, Room}

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

  defp count_items(items, display_id),
    do: Enum.filter(items, & &1.display_id == display_id) |> Enum.count()

  def active?(boolean), do: if boolean, do: "icon-active", else: "icon-inactive"

  def hide_collected_legend(hide_collected) do
    if hide_collected, do: "number of items still to collect", else: "number of items in display"
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

  def title(changeset) do
    action = if changeset.action == :insert, do: "Create", else: "Edit"
    struct = String.capitalize(struct_name(changeset.data))
    "#{action} #{struct}"
  end

  def action_submit(changeset) do
    action = if changeset.action == :insert, do: "create", else: "update"
    String.to_atom("#{action}_#{struct_name(changeset.data)}")
  end

  def visible_displays(displays, room_filter) do
    if is_nil(room_filter), do: displays, else: Enum.filter(displays, & &1.room_id == room_filter)
  end

  defp struct_name(struct) do
    case struct do
      %Display{} -> "display"
      %Item{} -> "item"
      %Mod{} -> "mod"
      %Room{} -> "room"
    end
  end
end
