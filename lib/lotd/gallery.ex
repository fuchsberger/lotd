defmodule Lotd.Gallery do
  @moduledoc """
  The Gallery context.
  """
  import Ecto.Query, warn: false

  alias Lotd.Repo
  alias Lotd.Accounts
  alias Lotd.Accounts.Character
  alias Lotd.Gallery.{Item, Room, Region, Display, Location, Mod}

  # GENERAL --------------------------------------------------------------------------------------
  def changeset(type) do
    case type do
      "character" -> Accounts.change_character(%Character{})
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

  def list_items(filters) do
    query = from i in Item,
      preload: [:mod, location: :region, display: :room],
      order_by: :name,
      limit: 200

    search = Keyword.get(filters, :search)

    query =
      if String.length(search) > 2 do
        # search
        from(i in query, where: ilike(i.name, ^"%#{search}%"))
      else
        #filter
        id = Keyword.get(filters, :filter_id)
        case Keyword.get(filters, :filter_type) do
          :display ->
            from(i in query, where: i.display_id == ^id)

          :location ->
            from(i in query, where: i.location_id == ^id)

          :region ->
            location_ids = Keyword.get(filters, :struct).locations |> Enum.map(& &1.id)
            from(i in query, where: i.location_id in ^location_ids)

          :mod ->
            from(i in query, where: i.mod_id == ^id)

          nil ->
            query
        end
      end

    query
    |> query_hide(filters)
    |> query_mods(filters)
    |> Repo.all()
  end

  defp query_hide(query, filters) do
    if Keyword.get(filters, :hide),
      do: where(query, [i], i.id not in ^Keyword.get(filters, :character_item_ids)),
      else: query
  end

  defp query_mods(query, filters) do
    if mod_ids = Keyword.get(filters, :character_mod_ids),
      do: where(query, [i], i.mod_id in ^mod_ids),
      else: query
  end

  # do: Repo.all from(i in Item, order_by: i.name, where: i.mod_id in ^user.active_character.mods)

  def get_item!(id), do: Repo.get!(Item, id)

  def change_item(%Item{} = item, params \\ %{}), do: Item.changeset(item, params)

  def delete_item(%Item{} = item), do: Repo.delete(item)

  # ROOMS ----------------------------------------------------------------------------------------
  def list_rooms, do: Repo.all from(r in Room, preload: :displays, order_by: r.name)

  def list_room_options,
    do: Repo.all from(r in Room, select: {r.name, r.id}, order_by: r.name)

  def get_rooms(displays), do: Repo.all(Ecto.assoc(displays, :room) |> order_by(:name))

  def get_room!(id), do: Repo.get!(Room, id)

  def change_room(%Room{} = room, params \\ %{}), do: Room.changeset(room, params)

  def delete_room(%Room{} = room), do: Repo.delete(room)

  # DISPLAYS -------------------------------------------------------------------------------------
  def list_displays, do: Repo.all from(d in Display, preload: [:room, :items], order_by: d.name)

  def list_display_options,
    do: Repo.all from(d in Display, select: {d.name, d.id}, order_by: d.name)

  def get_displays(items), do: Repo.all(Ecto.assoc(items, :display) |> order_by(:name))

  def get_display!(id), do: Repo.get!(Display, id)

  def change_display(%Display{} = display, params \\ %{}), do: Display.changeset(display, params)

  def delete_display(%Display{} = display), do: Repo.delete(display)

  # REGIONS --------------------------------------------------------------------------------------
  def list_regions do
    Repo.all from(r in Region,
      preload: [locations: [items: ^from(i in Item, select: i.id)]],
      order_by: r.name
    )
  end

  def list_region_options,
    do: Repo.all from(r in Region, select: {r.name, r.id}, order_by: r.name)

  def get_regions(locations), do: Repo.all(Ecto.assoc(locations, :region) |> order_by(:name))

  def get_region!(id), do: Repo.get!(Region, id)

  def change_region(%Region{} = region, params \\ %{}), do: Region.changeset(region, params)

  def delete_region(%Region{} = region), do: Repo.delete(region)

  # LOCATIONS ------------------------------------------------------------------------------------
  def list_locations(search, region_id, item_ids) do

    subquery = if item_ids,
      do: from(i in Item, select: map(i, [:id, :location_id]), where: i.id in ^item_ids),
      else: from(i in Item, select: map(i, [:id, :location_id]))

    from(l in Location,
      join: i in subquery(subquery), on: i.location_id == l.id,
      select: %{id: l.id, name: l.name},
      group_by: l.id,
      select_merge: %{count: count(i.id)},
      order_by: l.name
    )
    |> filter_search(search)
    |> filter_region(region_id)
    |> Repo.all()
  end

  defp filter_search(query, search) do
    if String.length(search) > 3,
      do: where(query, [l], ilike(l.name, ^"%#{search}%")),
      else: query
  end

  defp filter_region(query, nil), do: query
  defp filter_region(query, region_id), do:  where(query, [l], l.region_id == ^region_id)

  def list_location_options,
    do: Repo.all from(l in Location, select: {l.name, l.id}, order_by: l.name)

  def get_locations(items), do: Repo.all(Ecto.assoc(items, :location) |> order_by(:name))

  def get_location!(id), do: Repo.get!(Location, id)

  def change_location(%Location{} = location, params \\ %{}),
    do: Location.changeset(location, params)

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

  def create_mod(params) do
    %Mod{}
    |> change_mod(params)
    |> Repo.insert()
  end

  def change_mod(%Mod{} = mod, params \\ %{}), do: Mod.changeset(mod, params)

  def update_mod(%Mod{} = mod, params) do
    mod
    |> change_mod(params)
    |> Repo.update()
  end

  def delete_mod(%Mod{} = mod), do: Repo.delete(mod)
end
