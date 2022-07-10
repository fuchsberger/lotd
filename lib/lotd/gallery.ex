defmodule Lotd.Gallery do
  @moduledoc """
  The Gallery context.
  """
  import Ecto.Query, warn: false

  alias Lotd.Repo
  alias Lotd.Gallery.{Item, Room, Region, Display, Location, Mod}

  # ITEMS ----------------------------------------------------------------------------------------

  def item_query, do: from i in Item,
    preload: [:mod, location: :region, display: :room],
    order_by: i.name

  def list_items do
    from(i in Item, order_by: i.name, select: map(i, [:id, :display_id, :location_id, :mod_id, :name, :replica, :url]))
    |> Repo.all
  end

  def list_items(nil), do: Repo.all(item_query())

  def list_items(user) do
    character = Enum.find(user.characters, & &1.id == user.active_character_id)

    item_query()
    |> where([i], i.mod_id in ^character.mods)
    |> Repo.all()
  end

  def get_item!(id), do: Repo.get!(Item, id)

  def change_item(%Item{} = item, params \\ %{}), do: Item.changeset(item, params)

  # ROOMS ----------------------------------------------------------------------------------------

  def list_rooms do
    from(r in Room, select: map(r, [:name, :id]), order_by: r.name)
    |> Repo.all()
  end

  def get_room!(id), do: Repo.get!(Room, id)

  def change_room(%Room{} = room, params \\ %{}), do: Room.changeset(room, params)

  # DISPLAYS -------------------------------------------------------------------------------------

  def list_displays do
    from(d in Display, select: map(d, [:name, :id, :room_id]), order_by: d.name)
    |> Repo.all()
  end

  def list_display_options(room_id) do
    from(d in Display, select: {d.name, d.id}, order_by: d.name, where: d.room_id == ^room_id)
    |> Repo.all()
  end

  def get_display!(id), do: Repo.get!(Display, id)

  def change_display(%Display{} = display, params \\ %{}), do: Display.changeset(display, params)

  # REGIONS --------------------------------------------------------------------------------------

  def list_regions do
    from(r in Region, select: map(r, [:name, :id]), order_by: r.name)
    |> Repo.all()
  end

  def get_region!(id), do: Repo.get!(Region, id)

  def change_region(%Region{} = region, params \\ %{}), do: Region.changeset(region, params)

  # LOCATIONS ------------------------------------------------------------------------------------

  def list_locations do
    from(l in Location, select: map(l, [:name, :id, :region_id]), order_by: l.name)
    |> Repo.all()
  end

  def get_location!(id), do: Repo.get!(Location, id)

  def change_location(%Location{} = location, params \\ %{}),
    do: Location.changeset(location, params)

  # MODS -----------------------------------------------------------------------------------------

  def list_mods do
    mods = Repo.all(from(m in Mod, select: map(m, [:name, :id]), order_by: m.name))
    # move Vanilla / LOTD to front
    [Enum.find(mods, & &1.id == 1) | Enum.reject(mods, & &1.id == 1)]
  end

  def get_mod!(id), do: Repo.get!(Mod, id)

  def change_mod(%Mod{} = mod, params \\ %{}), do: Mod.changeset(mod, params)
end
