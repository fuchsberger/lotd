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
      Room -> get_room!(id)
      Display -> get_display!(id)
      Region -> get_region!(id)
      Location -> get_location!(id)
      Mod -> get_mod!(id)
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

  defp filter_search(query, search) do
    if String.length(search) > 3,
      do: where(query, [q], ilike(q.name, ^"%#{search}%")),
      else: query
  end

  # ITEMS ----------------------------------------------------------------------------------------
  def item_query, do: from(i in Item, order_by: i.name)

  def list_items, do: Repo.all from(i in Item, order_by: i.name)

  def list_items(search, filter, item_ids, mod_ids) do
    query = from i in Item,
      preload: [:mod, location: :region, display: :room],
      order_by: i.name,
      limit: 200

    cond do
      # search
      String.length(search) > 2 -> from(i in query, where: ilike(i.name, ^"%#{search}%"))

      #  no filter
      is_nil(filter) -> query

      # filter
      true ->
        case filter.__struct__ do
          Display -> from(i in query, where: i.display_id == ^filter.id)
          Room -> from(i in query, where: i.display_id in ^list_display_ids(filter.id))
          Location -> from(i in query, where: i.location_id == ^filter.id)
          Region -> from(i in query, where: i.location_id in ^list_location_ids(filter.id))
          Mod -> from(i in query, where: i.mod_id == ^filter.id)
        end
    end
    |> query_items(item_ids)
    |> query_mods(mod_ids)
    |> Repo.all()
  end

  defp query_items(query, false), do: query
  defp query_items(query, item_ids), do: where(query, [i], i.id not in ^item_ids)

  defp query_mods(query, false), do: query
  defp query_mods(query, mod_ids), do: where(query, [i], i.mod_id in ^mod_ids)

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

  defp list_display_ids(room_id) do
    Repo.all from(d in Display, select: d.id, where: d.room_id == ^room_id)
  end

  def list_display_options,
    do: Repo.all from(d in Display, select: {d.name, d.id}, order_by: d.name)

  def get_displays(items), do: Repo.all(Ecto.assoc(items, :display) |> order_by(:name))

  def get_display!(id), do: Repo.get!(Display, id)

  def change_display(%Display{} = display, params \\ %{}), do: Display.changeset(display, params)

  def delete_display(%Display{} = display), do: Repo.delete(display)

  # REGIONS --------------------------------------------------------------------------------------
  def list_regions(search) do
    from(r in Region, select: {r.id, r.name}, order_by: r.name)
    |> filter_search(search)
    |> Repo.all()
  end

  def get_region!(id), do: Repo.get!(Region, id)

  def change_region(%Region{} = region, params \\ %{}), do: Region.changeset(region, params)

  def delete_region(%Region{} = region), do: Repo.delete(region)

  # LOCATIONS ------------------------------------------------------------------------------------
  def list_locations(search, filter, item_ids) do

    subquery = if item_ids,
      do: from(i in Item, select: map(i, [:id, :location_id]), where: i.id in ^item_ids),
      else: from(i in Item, select: map(i, [:id, :location_id]))

    query = from(l in Location,
      join: i in subquery(subquery), on: i.location_id == l.id,
      select: %{id: l.id, name: l.name},
      group_by: l.id,
      select_merge: %{count: count(i.id)},
      order_by: l.name
    )

    cond do
      String.length(search) > 2 -> query |> filter_search(search) |> Repo.all()
      is_nil(filter) -> []
      filter.__struct__ == Region -> query |> filter_region(filter.id) |> Repo.all()
      filter.__struct__ == Location -> query |> filter_region(filter.region_id) |> Repo.all()
      true -> []
    end
  end

  defp filter_region(query, id), do:  where(query, [l], l.region_id == ^id)

  defp list_location_ids(region_id) do
    Repo.all from(l in Location, select: l.id, where: l.region_id == ^region_id)
  end

  def list_location_options,
    do: Repo.all from(l in Location, select: {l.name, l.id}, order_by: l.name)

  def get_locations(items), do: Repo.all(Ecto.assoc(items, :location) |> order_by(:name))

  def get_location!(id), do: Repo.get!(Location, id)

  def change_location(%Location{} = location, params \\ %{}),
    do: Location.changeset(location, params)

  def delete_location(%Location{} = location), do: Repo.delete(location)

  # MODS -----------------------------------------------------------------------------------------

  defp mod_query(item_ids \\ nil) do
    subquery = if is_nil(item_ids),
      do: from(i in Item, select: map(i, [:id, :mod_id])),
      else: from(i in Item, select: map(i, [:id, :mod_id]), where: i.id not in ^item_ids)

    from(m in Mod,
      left_join: i in subquery(subquery), on: i.mod_id == m.id,
      select: %{id: m.id, name: m.name},
      group_by: m.id,
      select_merge: %{item_count: count(i.id)},
      order_by: [m.id != 1, m.name]
    )
  end;

  @doc """
  Lists mods with item_count (all items)
  """
  def list_mods(), do: Repo.all(mod_query())

  @doc """
  Lists mods with item_count (remaining items)
  """
  def list_mods(item_ids) when is_list(item_ids), do: mod_query(item_ids) |> Repo.all()

  @doc """
  Lists mods filtered by search term with item_count (all items)
  """
  def list_mods(search) when is_binary(search) do
    mod_query()
    |> where([m], ilike(m.name, ^"%#{search}%"))
    |> Repo.all()
  end

  @doc """
  Lists mods filtered by search term with item_count (remaining items)
  """
  def list_mods(item_ids, search) do
    mod_query(item_ids)
    |> where([m], ilike(m.name, ^"%#{search}%"))
    |> Repo.all()
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
