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

  def find(module, query) do
    from(e in module, select: {e.id, e.name}, order_by: e.name, limit: 3)
    |> filter_search(query)
    |> Repo.all()
  end

  defp filter_search(query, search), do: where(query, [q], ilike(q.name, ^"%#{search}%"))

  # ITEMS ----------------------------------------------------------------------------------------

  def item_query, do: from i in Item,
    preload: [:mod, location: :region, display: :room],
    order_by: i.name,
    limit: 200

  def list_items(user, search, filter) do
    cond do
      # search
      String.length(search) > 2 ->
        item_query()
        |> filter_search(search)
        |> filter_hide(user)
        |> filter_user_mods(user)
        |> Repo.all()

      #  no filter
      is_nil(filter) ->
        item_query()
        |> filter_hide(user)
        |> filter_user_mods(user)
        |> Repo.all()

      # filter
      {type, id} = filter ->
        case type do
          :display -> from(i in item_query(), where: i.display_id == ^id)
          :location -> from(i in item_query(), where: i.location_id == ^id)
          :mod -> from(i in item_query(), where: i.mod_id == ^id)
          :room ->  from(i in item_query(), where: i.display_id in ^list_display_ids(id))
          :region -> from(i in item_query(), where: i.location_id in ^list_location_ids(id))
        end
        |> filter_hide(user)
        |> Repo.all()
    end
  end

  def filter_hide(query, user) do
    if(user && user.hide) do
      character = Enum.find(user.characters, & &1.id == user.active_character_id)
      where(query, [i], i.id not in ^character.items)
    else
      query
    end
  end

  def filter_user_mods(query, nil), do: query

  def filter_user_mods(query, user) do
    character = Enum.find(user.characters, & &1.id == user.active_character_id)
    where(query, [i], i.mod_id in ^character.mods)
  end

  def get_item!(id), do: Repo.get!(Item, id)

  def change_item(%Item{} = item, params \\ %{}), do: Item.changeset(item, params)

  # ROOMS ----------------------------------------------------------------------------------------
  def room_query do
    from r in Room,
      left_join: d in assoc(r, :displays),
      order_by: r.name,
      group_by: r.id,
      select_merge: %{display_count: count(d.id)}
  end

  def list_rooms(), do: Repo.all(room_query())

  def list_rooms(search) do
    room_query()
    |> filter_search(search)
    |> Repo.all()
  end

  def get_rooms(displays), do: Repo.all(Ecto.assoc(displays, :room) |> order_by(:name))

  def get_room!(id), do: Repo.get!(Room, id)

  def change_room(%Room{} = room, params \\ %{}), do: Room.changeset(room, params)

  def delete_room(%Room{} = room), do: Repo.delete(room)

  # DISPLAYS -------------------------------------------------------------------------------------
  def display_query(item_ids) do
    subquery = if item_ids,
      do: from(i in Item, select: map(i, [:id, :display_id]), where: i.id in ^item_ids),
      else: from(i in Item, select: map(i, [:id, :display_id]))

    from(d in Display,
      left_join: i in subquery(subquery), on: i.display_id == d.id,
      group_by: d.id,
      select_merge: %{item_count: count(i.id)},
      order_by: d.name
    )
  end

  def list_displays(item_ids, search) when is_binary(search) do
    item_ids
    |> display_query()
    |> filter_search(search)
    |> Repo.all()
  end

  def list_displays(item_ids, {:room, id}) do
    item_ids
    |> display_query()
    |> filter_room(id)
    |> Repo.all()
  end

  def list_displays(item_ids, {:display, id}) do
    room_id = from(d in Display, select: d.room_id) |> Repo.get(id)

    item_ids
    |> display_query()
    |> filter_room(room_id)
    |> Repo.all()
  end

  def list_displays(_item_ids, _filter), do: []

  defp filter_room(query, id), do: where(query, [d], d.room_id == ^id)

  defp list_display_ids(room_id) do
    Repo.all from(d in Display, select: d.id, where: d.room_id == ^room_id)
  end

  def list_display_options,
    do: Repo.all from(d in Display, select: {d.name, d.id}, order_by: d.name)

  def get_displays(items), do: Repo.all(Ecto.assoc(items, :display) |> order_by(:name))

  def get_display!(id), do: Repo.get!(Display, id)

  def change_display(%Display{} = display, params \\ %{}), do: Display.changeset(display, params)

  # REGIONS --------------------------------------------------------------------------------------
  def region_query do
    from r in Region,
      left_join: l in assoc(r, :locations),
      order_by: r.name,
      group_by: r.id,
      select_merge: %{location_count: count(l.id)}
  end

  def list_regions(), do: Repo.all(region_query())

  def list_regions(search) do
    region_query()
    |> filter_search(search)
    |> Repo.all()
  end

  def get_region!(id), do: Repo.get!(Region, id)

  def change_region(%Region{} = region, params \\ %{}), do: Region.changeset(region, params)

  def delete_region(%Region{} = region), do: Repo.delete(region)

  # LOCATIONS ------------------------------------------------------------------------------------
  def location_query(item_ids) do
    subquery = if item_ids,
      do: from(i in Item, select: map(i, [:id, :location_id]), where: i.id in ^item_ids),
      else: from(i in Item, select: map(i, [:id, :location_id]))

    from(l in Location,
      left_join: i in subquery(subquery), on: i.location_id == l.id,
      group_by: l.id,
      select_merge: %{item_count: count(i.id)},
      order_by: l.name
    )
  end

  def list_locations(item_ids, search) when is_binary(search) do
    item_ids
    |> location_query()
    |> filter_search(search)
    |> Repo.all()
  end

  def list_locations(item_ids, {:region, id}) do
    item_ids
    |> location_query()
    |> filter_region(id)
    |> Repo.all()
  end

  def list_locations(item_ids, {:location, id}) do
    region_id = from(l in Location, select: l.region_id) |> Repo.get(id)

    item_ids
    |> location_query()
    |> filter_region(region_id)
    |> Repo.all()
  end

  def list_locations(_item_ids, _filter), do: []

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

  # MODS -----------------------------------------------------------------------------------------

  defp mod_query(item_ids \\ nil) do
    subquery = if is_nil(item_ids),
      do: from(i in Item, select: map(i, [:id, :mod_id])),
      else: from(i in Item, select: map(i, [:id, :mod_id]), where: i.id not in ^item_ids)

    from(m in Mod,
      left_join: i in subquery(subquery), on: i.mod_id == m.id,
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
    |> filter_search(search)
    |> Repo.all()
  end

  @doc """
  Lists mods filtered by search term with item_count (remaining items)
  """
  def list_mods(item_ids, search) do
    mod_query(item_ids)
    |> filter_search(search)
    |> Repo.all()
  end

  def change_mod(%Mod{} = mod, params \\ %{}), do: Mod.changeset(mod, params)
end
