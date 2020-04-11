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
  def item_query, do: from(i in Item, order_by: i.name)

  def list_items, do: Repo.all from(i in Item, order_by: i.name)

  def list_items(user),
    do: Repo.all from(i in Item, order_by: i.name, where: i.mod_id in ^user.active_character.mods)

  def get_item!(id), do: Repo.get!(Item, id)

  def change_item(%Item{} = item), do: Item.changeset(item, %{})

  def delete_item(%Item{} = item), do: Repo.delete(item)

  # ROOMS ----------------------------------------------------------------------------------------
  def list_rooms, do: Repo.all from(r in Room, preload: :displays, order_by: r.name)

  def list_room_options,
    do: Repo.all from(r in Room, select: {r.name, r.id}, order_by: r.name)

  def get_rooms(displays), do: Repo.all(Ecto.assoc(displays, :room) |> order_by(:name))

  def get_room!(id), do: Repo.get!(Room, id)

  def change_room(%Room{} = room), do: Room.changeset(room, %{})

  def delete_room(%Room{} = room), do: Repo.delete(room)

  # DISPLAYS -------------------------------------------------------------------------------------
  def list_displays, do: Repo.all from(d in Display, preload: [:room, :items], order_by: d.name)

  def list_display_options,
    do: Repo.all from(d in Display, select: {d.name, d.id}, order_by: d.name)

  def get_displays(items), do: Repo.all(Ecto.assoc(items, :display) |> order_by(:name))

  def get_display!(id), do: Repo.get!(Display, id)

  def change_display(%Display{} = display), do: Display.changeset(display, %{})

  def delete_display(%Display{} = display), do: Repo.delete(display)

  # REGIONS --------------------------------------------------------------------------------------
  def list_regions, do: Repo.all from(r in Region, preload: :locations, order_by: r.name)

  def list_region_options,
    do: Repo.all from(r in Region, select: {r.name, r.id}, order_by: r.name)

  def get_regions(locations), do: Repo.all(Ecto.assoc(locations, :region) |> order_by(:name))

  def get_region!(id), do: Repo.get!(Region, id)

  def change_region(%Region{} = region), do: Region.changeset(region, %{})

  def delete_region(%Region{} = region), do: Repo.delete(region)

  # LOCATIONS ------------------------------------------------------------------------------------
  def list_locations, do: Repo.all from(r in Location, preload: [:region, :items], order_by: r.name)

  def list_location_options,
    do: Repo.all from(l in Location, select: {l.name, l.id}, order_by: l.name)

  def get_locations(items), do: Repo.all(Ecto.assoc(items, :location) |> order_by(:name))

  def get_location!(id), do: Repo.get!(Location, id)

  def change_location(%Location{} = location), do: Location.changeset(location, %{})

  def delete_location(%Location{} = location), do: Repo.delete(location)

  # MODS -----------------------------------------------------------------------------------------
  def list_mods do
    Repo.all from(m in Mod,
      order_by: [m.id != 1, m.name],
      preload: [items: ^from(i in Item, select: i.id)]
    )
  end

  def list_mod_options,
    do: Repo.all from(m in Mod, select: {m.name, m.id}, order_by: m.name)

  def list_mods(ids), do: Repo.all from(d in Mod, order_by: d.name, where: d.id in ^ids)

  def get_mods(items), do: Repo.all(Ecto.assoc(items, :mod) |> order_by(:name))

  def get_mod!(id), do: Repo.get!(Mod, id)

  def change_mod(%Mod{} = mod), do: Mod.changeset(mod, %{})

  def delete_mod(%Mod{} = mod), do: Repo.delete(mod)
end
