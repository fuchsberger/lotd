defmodule Lotd.Gallery do
  @moduledoc """
  The Gallery context.
  """
  import Ecto.Query, warn: false

  alias Lotd.Repo
  alias Lotd.Accounts.Character
  alias Lotd.Gallery.{Item, Room, Region, Display, Location, Mod}

  # GENERAL --------------------------------------------------------------------------------------
  def changeset(type) do
    case type do
      "item" -> change_item(%Item{})
      "room" -> change_room(%Room{})
      "display" -> change_display(%Display{})
      "region" -> change_region(%Region{})
      "location" -> change_location(%Location{})
      "mod" -> change_mod(%Mod{})
    end
  end

  def changeset(type, id) do
    case type do
      "item" -> change_item(get_item!(id))
      "room" -> change_room(get_room!(id))
      "display" -> change_display(get_display!(id))
      "region" -> change_region(get_region!(id))
      "location" -> change_location(get_location!(id))
      "mod" -> change_mod(get_mod!(id))
    end
  end

  def get(type, id) do
    case type do
      "room" -> get_room!(id)
      "display" -> get_display!(id)
      "region" -> get_region!(id)
      "location" -> get_location!(id)
      "mod" -> get_mod!(id)
      _ -> nil
    end
  end

  def find(module, query), do:
    Repo.all from(e in module,
      select: {e.id, e.name},
      order_by: e.name,
      where: ilike(e.name, ^"%#{query}%"),
      limit: 3
    )

  # ITEMS ----------------------------------------------------------------------------------------
  def item_query, do: from(i in Item,
    order_by: i.name,
    preload: [:mod, display: [:room], location: [:region]],
    limit: 200
  )

  def list_items(assigns) do
    query =
      item_query()
      |> query_character(assigns.character, assigns.hide)
      |> query_filter(assigns.filter)
      |> query_search(assigns.search)

    Repo.all(query)
  end

  defp query_character(query, nil, _hide), do: query

  defp query_character(query, character, false),
    do: query |> where([i], i.mod_id in ^character.mods)

  defp query_character(query, character, true),
    do: query |> where([i], i.mod_id in ^character.mods and not(i.id in ^character.items))

  defp query_filter(query, nil), do: query

  defp query_filter(query, %Room{} = filter) do
    display_ids = Repo.all(from d in Display, select: d.id, where: d.room_id == ^filter.id)
    query |> where([i], i.display_id in ^display_ids)
  end

  defp query_filter(query, %Display{} = filter),
    do: query |> where([i], i.display_id == ^filter.id)

  defp query_filter(query, %Region{} = filter) do
    location_ids = Repo.all(from l in Location, select: l.id, where: l.region_id == ^filter.id)
    query |> where([i], i.location_id in ^location_ids)
  end

  defp query_filter(query, %Location{} = filter),
    do: query |> where([i], i.location_id == ^filter.id)

  defp query_filter(query, %Mod{} = filter),
    do: query |> where([i], i.mod_id == ^filter.id)

  defp query_search(query, search) do
    if String.length(search) > 2,
      do: query |> where([i], ilike(i.name, ^"%#{search}%")),
      else: query
  end

  def list_items(), do:
    Repo.all from(i in Item,
      preload: [:mod, display: [:room], location: [:region]],
      order_by: i.name
    )

  def list_items(query, nil), do:
    Repo.all from(i in item_query(), where: ilike(i.name, ^"%#{query}%"))

  def list_items(query, character), do:
    Repo.all from(i in item_query(),
      preload: [characters: ^from(c in Character, select: c.id, where: c.id == ^character.id)],
      where: i.mod_id in ^character.mods and ilike(i.name, ^"%#{query}%")
    )

  def list_items("room", id, nil) do
    display_ids = Repo.all from(d in Display, select: d.id, where: d.room_id == ^id)
    Repo.all from(i in item_query(), where: i.display_id in ^display_ids)
  end

  def list_items("room", id, character) do
    display_ids = Repo.all from(d in Display, select: d.id, where: d.room_id == ^id)
    Repo.all from(i in item_query(),
      where: i.display_id in ^display_ids and i.mod_id in ^character.mods
    )
  end

  def list_items("display", id, nil) do
    Repo.all from(i in item_query(), where: i.display_id == ^id)
  end

  def list_items("display", id, character) do
    Repo.all from(i in item_query(), where: i.display_id == ^id and i.mod_id in ^character.mods)
  end

  def list_items("region", id, nil) do
    location_ids = Repo.all from(l in Location, select: l.id, where: l.region_id == ^id)
    Repo.all from(i in item_query(), where: i.location_id in ^location_ids)
  end

  def list_items("region", id, character) do
    location_ids = Repo.all from(l in Location, select: l.id, where: l.region_id == ^id)
    Repo.all from(i in item_query(),
      where: i.location_id in ^location_ids and i.mod_id in ^character.mods
    )
  end

  def list_items("location", id, nil) do
    Repo.all from(i in item_query(), where: i.location_id == ^id)
  end

  def list_items("location", id, character) do
    Repo.all from(i in item_query(), where: i.location_id == ^id and i.mod_id in ^character.mods)
  end

  def list_items("mod", id, nil) do
    Repo.all from(i in item_query(), where: i.mod_id == ^id)
  end

  def list_items("mod", id, character) do
    Repo.all from(i in item_query(), where: i.mod_id == ^id and i.mod_id in ^character.mods)
  end

  def get_item!(id), do: Repo.get!(Item, id)

  def change_item(%Item{} = item), do: Item.changeset(item, %{})

  def delete_item(%Item{} = item), do: Repo.delete(item)

  # ROOMS ----------------------------------------------------------------------------------------
  def list_rooms, do: Repo.all from(r in Room, preload: :displays, order_by: r.name)

  def list_room_options,
    do: Repo.all from(r in Room, select: {r.name, r.id}, order_by: r.name)

  def get_room!(id), do: Repo.get!(Room, id)

  def change_room(%Room{} = room), do: Room.changeset(room, %{})

  def delete_room(%Room{} = room), do: Repo.delete(room)

  # DISPLAYS -------------------------------------------------------------------------------------
  def list_displays, do: Repo.all from(d in Display, preload: [:room, :items], order_by: d.name)

  def list_display_options,
    do: Repo.all from(d in Display, select: {d.name, d.id}, order_by: d.name)

  def get_display!(id), do: Repo.get!(Display, id)

  def change_display(%Display{} = display), do: Display.changeset(display, %{})

  def delete_display(%Display{} = display), do: Repo.delete(display)

  # REGIONS --------------------------------------------------------------------------------------
  def list_regions, do: Repo.all from(r in Region, preload: :locations, order_by: r.name)

  def list_region_options,
    do: Repo.all from(r in Region, select: {r.name, r.id}, order_by: r.name)

  def get_region!(id), do: Repo.get!(Region, id)

  def change_region(%Region{} = region), do: Region.changeset(region, %{})

  def delete_region(%Region{} = region), do: Repo.delete(region)

  # LOCATIONS ------------------------------------------------------------------------------------
  def list_locations, do: Repo.all from(r in Location, preload: [:region, :items], order_by: r.name)

  def list_location_options,
    do: Repo.all from(l in Location, select: {l.name, l.id}, order_by: l.name)

  def get_location!(id), do: Repo.get!(Location, id)

  def change_location(%Location{} = location), do: Location.changeset(location, %{})

  def delete_location(%Location{} = location), do: Repo.delete(location)

  # MODS -----------------------------------------------------------------------------------------
  def list_mods, do: Repo.all from(d in Mod, preload: :items, order_by: d.name)

  def list_mod_options,
    do: Repo.all from(m in Mod, select: {m.name, m.id}, order_by: m.name)

  def list_mods(ids), do: Repo.all from(d in Mod, order_by: d.name, where: d.id in ^ids)

  def get_mod!(id), do: Repo.get!(Mod, id)

  def change_mod(%Mod{} = mod), do: Mod.changeset(mod, %{})

  def delete_mod(%Mod{} = mod), do: Repo.delete(mod)
end
