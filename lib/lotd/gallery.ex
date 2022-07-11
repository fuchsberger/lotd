defmodule Lotd.Gallery do
  @moduledoc """
  The Gallery context.
  """
  import Ecto.Query

  alias Lotd.Repo
  alias Lotd.Gallery.{Item, Room, Region, Display, Location, Mod}

  # ITEMS ----------------------------------------------------------------------------------------

  def list_items do
    from(i in Item, order_by: i.name, select: map(i, [:id, :display_id, :location_id, :mod_id, :name, :replica, :url]))
    |> Repo.all
  end

  def list_items(:complete) do
    from(i in Item, preload: [
      mod: ^from(m in Mod, select: m.initials),
      display: [room: ^from(r in Room, select: r.name)],
      location: [region: ^from(r in Region, select: r.name)],
    ])
    |> Repo.all
  end

  def get_item!(id), do: Repo.get!(Item, id)

  def change_item(%Item{} = item, params \\ %{}), do: Item.changeset(item, params)

  def create_item(attrs \\ %{}) do
    %Item{}
    |> Item.changeset(attrs)
    |> Repo.insert()
  end

  def update_item(%Item{} = item, attrs) do
    item
    |> Item.changeset(attrs)
    |> Repo.update()
  end

  def delete_item(%Item{} = item), do: Repo.delete(item)

  # ROOMS ----------------------------------------------------------------------------------------

  def list_rooms do
    from(r in Room, select: map(r, [:name, :id]), order_by: r.name)
    |> Repo.all()
  end

  def get_room!(id), do: Repo.get!(Room, id)

  def change_room(%Room{} = room, params \\ %{}), do: Room.changeset(room, params)

  def create_room(attrs \\ %{}) do
    %Room{}
    |> Room.changeset(attrs)
    |> Repo.insert()
  end

  def update_room(%Room{} = room, attrs) do
    room
    |> Room.changeset(attrs)
    |> Repo.update()
  end

  def delete_room(%Room{} = room), do: Repo.delete(room)

  # DISPLAYS -------------------------------------------------------------------------------------

  def list_displays do
    from(d in Display, select: map(d, [:name, :id, :room_id]), order_by: d.name)
    |> Repo.all()
  end

  def get_display!(id), do: Repo.get!(Display, id)

  def change_display(%Display{} = display, params \\ %{}), do: Display.changeset(display, params)

  def create_display(attrs \\ %{}) do
    %Display{}
    |> Display.changeset(attrs)
    |> Repo.insert()
  end

  def update_display(%Display{} = display, attrs) do
    display
    |> Display.changeset(attrs)
    |> Repo.update()
  end

  def delete_display(%Display{} = display), do: Repo.delete(display)

  # REGIONS --------------------------------------------------------------------------------------

  def list_regions do
    from(r in Region, select: map(r, [:name, :id]), order_by: r.name)
    |> Repo.all()
  end

  def get_region!(id), do: Repo.get!(Region, id)

  def change_region(%Region{} = region, params \\ %{}), do: Region.changeset(region, params)

  def create_region(attrs \\ %{}) do
    %Region{}
    |> Region.changeset(attrs)
    |> Repo.insert()
  end

  def update_region(%Region{} = region, attrs) do
    region
    |> Region.changeset(attrs)
    |> Repo.update()
  end

  def delete_region(%Region{} = region), do: Repo.delete(region)

  # LOCATIONS ------------------------------------------------------------------------------------

  def list_locations do
    from(l in Location, select: map(l, [:name, :id, :region_id]), order_by: l.name)
    |> Repo.all()
  end

  def get_location!(id), do: Repo.get!(Location, id)

  def change_location(%Location{} = location, params \\ %{}),
    do: Location.changeset(location, params)

  def create_location(attrs \\ %{}) do
    %Location{}
    |> Location.changeset(attrs)
    |> Repo.insert()
  end

  def update_location(%Location{} = location, attrs) do
    location
    |> Location.changeset(attrs)
    |> Repo.update()
  end

  def delete_location(%Location{} = location), do: Repo.delete(location)

  # MODS -----------------------------------------------------------------------------------------

  def list_mods do
    mods = Repo.all(from(m in Mod, select: map(m, [:name, :initials, :id]), order_by: m.name))
    # move Vanilla / LOTD to front
    [Enum.find(mods, & &1.id == 1) | Enum.reject(mods, & &1.id == 1)]
  end

  def get_mod!(id), do: Repo.get!(Mod, id)

  def change_mod(%Mod{} = mod, params \\ %{}), do: Mod.changeset(mod, params)

  def create_mod(attrs \\ %{}) do
    %Mod{}
    |> Mod.changeset(attrs)
    |> Repo.insert()
  end

  def update_mod(%Mod{} = mod, attrs) do
    mod
    |> Mod.changeset(attrs)
    |> Repo.update()
  end

  def delete_mod(%Mod{} = mod), do: Repo.delete(mod)
end
