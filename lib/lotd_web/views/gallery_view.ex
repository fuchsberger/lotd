defmodule LotdWeb.GalleryView do
  use LotdWeb, :view

  alias Lotd.Gallery
  alias Lotd.Accounts.Character
  alias Lotd.Gallery.{Room, Display, Region, Location, Mod}

  def character(nil), do: nil
  def character(user), do: user.active_character

  def character?(struct), do: struct.__struct__ == Character

  def filter?(socket) do
    cond do
      socket.assigns.filter_mod -> :mod
      socket.assigns.filter_display -> :display
      socket.assigns.filter_room -> :room
      socket.assigns.filter_location -> :location
      socket.assigns.filter_region -> :region
      true -> nil
    end
  end

  def filtered_struct(socket) do
    case filter?(socket) do
      :display -> Enum.find socket.assigns.displays, & &1.id == socket.assigns.filter_display
      :room -> Enum.find socket.assigns.rooms, & &1.id == socket.assigns.filter_room
      :location -> Enum.find socket.assigns.locations, & &1.id == socket.assigns.filter_location
      :region -> Enum.find socket.assigns.regions, & &1.id == socket.assigns.filter_region
      :mod -> Enum.find socket.assigns.mods, & &1.id == socket.assigns.filter_mod
      nil -> nil
    end
  end

  def filtered_entries(entries, struct, items) do
    case struct do
      %Display{id: id} ->
        Enum.filter(entries, & &1.display_id == id)

      %Room{id: id} ->
        display_ids = Enum.filter(entries, & &1.room_id == id) |> Enum.map(& &1.id)
        Enum.filter(items, & Enum.member?(display_ids, &1.display_id))

      %Location{id: id} ->
        Enum.filter(entries, & &1.location_id == id)

      %Region{id: id} ->
        location_ids = Enum.filter(entries, & &1.region_id == id) |> Enum.map(& &1.id)
        Enum.filter(items, & Enum.member?(location_ids, &1.location_id))

      %Mod{id: id} ->
        Enum.filter(entries, & &1.mod_id == id)
    end
  end

  def form_action(changeset) do
    if changeset.data.id, do: :update, else: :insert
  end

  def form_btn_text(changeset) do
    if changeset.data.id, do: "Update", else: "Create"
  end

  def form_heading_text(changeset) do
    if changeset.data.id,
      do: "Edit #{type(changeset.data)}",
      else: "Add #{type(changeset.data)}"
  end

  defp found(_items, nil), do: nil

  defp found(items, character) do
    items
    |> Enum.filter(& Enum.member?(character.items, &1.id))
    |> Enum.count()
  end

  def filtered?(filter, struct) do
    case struct do
      %Room{} ->
        (filter.__struct__ == struct.__struct__ && filter.id == struct.id) ||
        (filter.__struct__ == Display && filter.room_id == struct.id)

      %Region{} ->
        (filter.__struct__ == struct.__struct__ && filter.id == struct.id) ||
        (filter.__struct__ == Location && filter.region_id == struct.id)

      _ ->
        not is_nil(filter) && filter.__struct__ == struct.__struct__ && filter.id == struct.id
    end
  end

  def type(struct) do
    struct.__struct__
    |> to_string()
    |> String.split(".")
    |> List.last()
  end

  defp search_entries(entries, search) do
    if String.length(search) >= 3 do
      query = String.downcase(search, :ascii)
      Enum.filter(entries, & String.contains?(String.downcase(&1.name, :ascii), query))
    else
      entries
    end
  end

  def visible_entries(entries, search, filter, assoc, user, items \\ nil) do

    entries
    |> search_entries(search)
    |> Enum.map(fn entry ->
        items = filtered_entries(assoc, entry, items)
        Map.merge(entry, %{
          count: Enum.count(items),
          found: found(items, character(user)),
          filtered?: filtered?(filter, entry)
        })
      end)
    # |> Enum.reject(& hide?(user) && &1.found == &1.count)
  end

  def visible_displays(displays, filter) do
    case filter do
      %Display{room_id: id} -> Enum.filter(displays, & &1.room_id == id)
      %Room{id: id} -> Enum.filter(displays, & &1.room_id == id)
      _ -> []
    end
  end

  def visible_locations(locations, filter) do
    case filter do
      %Location{region_id: id} -> Enum.filter(locations, & &1.region_id == id)
      %Region{id: id} -> Enum.filter(locations, & &1.region_id == id)
      _ -> []
    end
  end

  def visible_items(items, rooms, displays, regions, locations, mods, search, filter, user) do
    items =
      if String.length(search) >= 3 do
        query = String.downcase(search, :ascii)
        Enum.filter(items, & String.contains?(String.downcase(&1.name, :ascii), query))
      else
        case filter do
          %Display{id: id} ->
            Enum.filter(items, & &1.display_id == id)

          %Room{id: id} ->
            display_ids = Enum.filter(displays, & &1.room_id == id) |> Enum.map(& &1.id)
            Enum.filter(items, & Enum.member?(display_ids, &1.display_id))

          %Location{id: id} ->
            Enum.filter(items, & &1.location_id == id)

          %Region{id: id} ->
            location_ids = Enum.filter(locations, & &1.region_id == id) |> Enum.map(& &1.id)
            Enum.filter(items, & Enum.member?(location_ids, &1.location_id))

          %Mod{id: id} ->
            Enum.filter(items, & &1.mod_id == id)
        end
      end

    # items = if hide?(user),
    #   do: Enum.reject(items, & Enum.member?(user.active_character.items, &1.id)),
    #   else: items

    Enum.map(items, fn item ->
      display = Enum.find(displays, & &1.id == item.display_id)
      room = Enum.find(rooms, & &1.id == display.room_id)
      location = Enum.find(locations, & &1.id == item.location_id)
      region = if location, do: Enum.find(regions, & &1.id == location.region_id), else: nil
      mod = Enum.find(mods, & &1.id == item.mod_id)

      item
      |> Map.put(:display, display)
      |> Map.put(:region, region)
      |> Map.put(:room, room)
      |> Map.put(:location, location)
      |> Map.put(:mod, mod)
    end)
  end
end
