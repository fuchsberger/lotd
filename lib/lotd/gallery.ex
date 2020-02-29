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
      "item" -> Gallery.change_item(get_item!(id))
      "room" -> Gallery.change_room(get_room!(id))
      "display" -> Gallery.change_display(get_display!(id))
      "region" -> Gallery.change_region(get_region!(id))
      "location" -> Gallery.change_location(get_location!(id))
      "mod" -> Gallery.change_mod(get_mod!(id))
    end
  end

  # ITEMS ----------------------------------------------------------------------------------------
  def list_items do
    Repo.all from(i in Item,
      preload: [:mod, display: [:room], location: [:region]],
      order_by: i.name
    )
  end

  def list_items(character), do:
    Repo.all from(i in Item,
      order_by: i.name,
      preload: [
        :mod,
        characters: ^from(c in Character, select: c.id, where: c.id == ^character.id),
        location: [:region],
        display: [:room]
      ],
      where: i.mod_id in ^character.mods
    )

  def get_item!(id), do: Repo.get!(Item, id)

  def change_item(%Item{} = item), do: Item.changeset(item, %{})

  def delete_item(%Item{} = item), do: Repo.delete(item)

  # ROOMS ----------------------------------------------------------------------------------------
  def list_rooms, do: Repo.all from(r in Room, order_by: r.name)

  def get_room!(id), do: Repo.get!(Room, id)

  def change_room(%Room{} = room), do: Room.changeset(room, %{})

  def delete_room(%Room{} = room), do: Repo.delete(room)

  # DISPLAYS -------------------------------------------------------------------------------------
  def list_displays, do: Repo.all from(d in Display, preload: :room, order_by: d.name)

  def get_display!(id), do: Repo.get!(Display, id)

  def change_display(%Display{} = display), do: Display.changeset(display, %{})

  def delete_display(%Display{} = display), do: Repo.delete(display)

  # REGIONS --------------------------------------------------------------------------------------
  def list_regions, do: Repo.all from(r in Region, order_by: r.name)

  def get_region!(id), do: Repo.get!(Region, id)

  def change_region(%Region{} = region), do: Region.changeset(region, %{})

  def delete_region(%Region{} = region), do: Repo.delete(region)

  # LOCATIONS ------------------------------------------------------------------------------------
  def list_locations, do: Repo.all from(r in Location, preload: :region, order_by: r.name)

  def get_location!(id), do: Repo.get!(Location, id)

  def change_location(%Location{} = location), do: Location.changeset(location, %{})

  def delete_location(%Location{} = location), do: Repo.delete(location)

  # MODS -----------------------------------------------------------------------------------------
  def list_mods, do: Repo.all from(d in Mod, order_by: d.name)

  def list_mods(ids), do: Repo.all from(d in Mod, order_by: d.name, where: d.id in ^ids)

  def get_mod!(id), do: Repo.get!(Mod, id)

  def change_mod(%Mod{} = mod), do: Mod.changeset(mod, %{})

  def delete_mod(%Mod{} = mod), do: Repo.delete(mod)
end
