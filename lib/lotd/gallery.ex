defmodule Lotd.Gallery do
  @moduledoc """
  The Gallery context.
  """
  import Ecto.Query

  alias Lotd.Repo
  alias Lotd.Gallery.{Item, ItemFilter, Region, Location, Mod}
  alias Lotd.Accounts.User

  # ITEMS ----------------------------------------------------------------------------------------

  def list_items, do: Repo.all(from(i in Item, order_by: i.name, preload: [:location]))

  def item_options, do: Repo.all(from(i in Item, select: {i.name, i.id}))

  def list_items(mods) do
    Repo.all(from(i in Item, order_by: i.name, preload: [:location], where: i.mod_id in ^mods))
  end

  def get_item!(id), do: Repo.get!(Item, id)

  def preload_item(%Item{} = item), do: Repo.preload(item, [:location])

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

  # REGIONS --------------------------------------------------------------------------------------

  def list_regions do
    from(r in Region,
      preload: [locations: [items: ^from(i in Item, select: i.id)]],
      order_by: r.name
    )
    |> Repo.all()
  end

  def region_options, do: Repo.all(from(r in Region, select: {r.name, r.id}, order_by: r.name))

  def get_region!(id), do: Repo.get!(Region, id)

  def preload_region(%Region{} = region),
    do: Repo.preload(region, [locations: [items: from(i in Item, select: i.id)]])

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
    from(d in Location, preload: [items: ^from(i in Item, select: i.id)])
    |> Repo.all()
  end

  def location_options, do: Repo.all(from(l in Location, select: {l.name, l.id}, order_by: l.name))

  def get_location!(id), do: Repo.get!(Location, id)

  def preload_location(%Location{} = location),
    do: Repo.preload(location, [items: from(i in Item, select: i.id)])

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
    mods = Repo.all(from(m in Mod, order_by: m.name, preload: [
      items: ^from(i in Item, select: i.id),
      users: ^from(u in User, select: u.id)
    ]))
    # move Vanilla / LOTD to front
    [Enum.find(mods, & &1.id == 1) | Enum.reject(mods, & &1.id == 1)]
  end

  def mod_options, do: Repo.all(from(m in Mod, select: {m.name, m.id}, order_by: m.name))

  def preload_mod(%Mod{} = mod), do: Repo.preload(mod, [:items, :users])

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

  # ITEM FILTER ----------------------------------------------------------------------------------
  def change_item_filter(%ItemFilter{} = filter, params \\ %{}),
    do: ItemFilter.changeset(filter, params)

end
