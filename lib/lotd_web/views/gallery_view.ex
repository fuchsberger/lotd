defmodule LotdWeb.GalleryView do
  use LotdWeb, :view

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

  def room_options(items, nil) do
    displays = list_assoc(items, :display)
    rooms = list_assoc(displays, :room)

    Enum.map(rooms, fn room ->
      room_displays = Enum.filter(displays, & &1.room_id == room.id) |> Enum.map(& &1.id)
      %{
        id: room.id,
        name: room.name,
        count: Enum.count(items, & Enum.member?(room_displays, &1.display_id))
      }
    end)
  end

  def room_options(items, character_items) do
    displays = list_assoc(items, :display)
    rooms = list_assoc(displays, :room)
    character_items = Enum.filter(items, & Enum.member?(character_items, &1.id))

    Enum.map(rooms, fn room ->
      room_displays = Enum.filter(displays, & &1.room_id == room.id) |> Enum.map(& &1.id)
      %{
        id: room.id,
        name: room.name,
        found: Enum.count(character_items, & Enum.member?(room_displays, &1.display_id)),
        count: Enum.count(items, & Enum.member?(room_displays, &1.display_id))
      }
    end)
  end

  def display_options(items, filter, id, nil) do
    displays = case {filter, id} do
      {_, nil} -> []
      {"room", id} -> list_assoc(items, :display) |> Enum.filter(& &1.room_id == id)
      {"display", id} ->
        displays = list_assoc(items, :display)
        room_id = Enum.find(displays, & &1.id == id).room_id
        Enum.filter(displays, & &1.room_id == room_id)
      _ -> []
    end

    Enum.map(displays, fn display ->
      %{
        id: display.id,
        name: display.name,
        count: Enum.count(items, & &1.display_id == display.id)
      }
    end)
  end

  def display_options(items, filter, id, character_items) do
    displays = case {filter, id} do
      {_, nil} -> []
      {"room", id} -> list_assoc(items, :display) |> Enum.filter(& &1.room_id == id)
      {"display", id} ->
        displays = list_assoc(items, :display)
        room_id = Enum.find(displays, & &1.id == id).room_id
        Enum.filter(displays, & &1.room_id == room_id)
      _ -> []
    end

    character_items = Enum.filter(items, & Enum.member?(character_items, &1.id))

    Enum.map(displays, fn display ->
      %{
        id: display.id,
        name: display.name,
        found: Enum.count(character_items, & &1.display_id == display.id),
        count: Enum.count(items, & &1.display_id == display.id)
      }
    end)
  end

  def region_options(items, nil) do
    locations = list_assoc(items, :location)
    regions = list_assoc(locations, :region)

    Enum.map(regions, fn region ->
      region_locations = Enum.filter(locations, & &1.region_id == region.id) |> Enum.map(& &1.id)
      %{
        id: region.id,
        name: region.name,
        count: Enum.count(items, & Enum.member?(region_locations, &1.location_id))
      }
    end)
  end

  def region_options(items, character_items) do
    locations = list_assoc(items, :location)
    regions = list_assoc(locations, :region)
    character_items = Enum.filter(items, & Enum.member?(character_items, &1.id))

    Enum.map(regions, fn region ->
      region_locations = Enum.filter(locations, & &1.region_id == region.id) |> Enum.map(& &1.id)
      %{
        id: region.id,
        name: region.name,
        found: Enum.count(character_items, & Enum.member?(region_locations, &1.location_id)),
        count: Enum.count(items, & Enum.member?(region_locations, &1.location_id))
      }
    end)
  end

  def location_options(items, filter, id, nil) do
    locations = case {filter, id} do
      {_, nil} -> []
      {"region", id} -> list_assoc(items, :location) |> Enum.filter(& &1.region_id == id)
      {"location", id} ->
        locations = list_assoc(items, :location)
        region_id = Enum.find(locations, & &1.id == id).region_id
        Enum.filter(locations, & &1.region_id == region_id)
      _ -> []
    end

    Enum.map(locations, fn location ->
      %{
        id: location.id,
        name: location.name,
        count: Enum.count(items, & &1.location_id == location.id)
      }
    end)
  end

  def location_options(items, filter, id, character_items) do
    locations = case {filter, id} do
      {_, nil} -> []
      {"region", id} -> list_assoc(items, :location) |> Enum.filter(& &1.region_id == id)
      {"location", id} ->
        locations = list_assoc(items, :location)
        region_id = Enum.find(locations, & &1.id == id).region_id
        Enum.filter(locations, & &1.region_id == region_id)
        _ -> []
    end
    character_items = Enum.filter(items, & Enum.member?(character_items, &1.id))

    Enum.map(locations, fn location ->
      %{
        id: location.id,
        name: location.name,
        found: Enum.count(character_items, & &1.location_id == location.id),
        count: Enum.count(items, & &1.location_id == location.id)
      }
    end)
  end

  def mod_options(items, nil) do
    mods = list_assoc(items, :mod)
    Enum.map(mods, fn mod ->
      %{
        id: mod.id,
        name: mod.name,
        count: Enum.count(items, & &1.mod_id == mod.id)
      }
    end)
  end

  def mod_options(items, character_items) do
    mods = list_assoc(items, :mod)
    character_items = Enum.filter(items, & Enum.member?(character_items, &1.id))

    Enum.map(mods, fn mod ->
      %{
        id: mod.id,
        name: mod.name,
        found: Enum.count(character_items, & &1.mod_id == mod.id),
        count: Enum.count(items, & &1.mod_id == mod.id)
      }
    end)
  end

  def visible_displays(displays, filter, id) do
    case {filter, id} do
      {_, nil} -> displays
      {"room", id} -> Enum.filter(displays, & &1.room_id == id)
      _ -> displays
    end
  end

  def visible_items(items, character_items, filter, filter_val, hide, search) do
    displays = list_assoc(items, :display)
    locations = list_assoc(items, :location)

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

  defp list_assoc(collection, assoc) do
    collection
    |> Enum.map(& Map.get(&1, assoc))
    |> Enum.reject(& &1 == nil)
    |> Enum.uniq()
    |> Enum.sort_by(& &1.name, :asc)
  end
end
