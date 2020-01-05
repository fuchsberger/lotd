defmodule Lotd.Museum do
  @moduledoc """
  The Museum context.
  """
  import Ecto.Query, warn: false

  alias Lotd.Repo
  alias Lotd.Museum.{Display, Item, Mod, Room}

  # SORTING

  def get_form_id(id_string) do
    if id_string == "None" do
      nil
    else
      [_head, tail ] = String.split(id_string, "(")
      [id, _tail ] = String.split(tail, ")")
      id
    end
  end

  # ROOMS
  def create_room(attrs) do
    %Room{}
    |> Room.changeset(attrs)
    |> Repo.insert()
  end

  def get_room_id!(name), do: Repo.one!(from(r in Room, select: r.id, where: r.name == ^name))

  # DISPLAYS

  def list_displays, do: Repo.all from(d in Display, preload: [ items: ^Repo.ids(Item) ])

  def get_display_id!(name),
    do: Repo.one!(from(d in Display, select: d.id, where: d.name == ^name))

  def create_display(attrs) do
    %Display{}
    |> Display.changeset(attrs)
    |> Repo.insert()
  end

  # ITEMS

  def list_items(sort, dir, search, user, page \\ 1)

  def list_items(sort, dir, search, nil, page) do
    case {sort, dir} do
      {"display", "asc"} ->
        from(i in Item,
          left_join: d in assoc(i, :display),
          left_join: r in assoc(i, :room),
          select: %{ id: i.id, name: i.name },
          select_merge: %{ display: d.name, room: r.name },
          order_by: [asc: d.name],
          where: ilike(i.name, ^"%#{search}%")
        )
      {"display", "desc"} ->
        from(i in Item,
          left_join: d in assoc(i, :display),
          left_join: r in assoc(i, :room),
          select: %{ id: i.id, name: i.name },
          select_merge: %{ display: d.name, room: r.name },
          order_by: [desc: d.name],
          where: ilike(i.name, ^"%#{search}%")
        )
        {"room", "asc"} ->
          from(i in Item,
            left_join: d in assoc(i, :display),
            left_join: r in assoc(i, :room),
            select: %{ id: i.id, name: i.name },
            select_merge: %{ display: d.name, room: r.name },
            order_by: [asc: r.name],
            where: ilike(i.name, ^"%#{search}%")
          )
        {"room", "desc"} ->
          from(i in Item,
            left_join: d in assoc(i, :display),
            left_join: r in assoc(i, :room),
            select: %{ id: i.id, name: i.name },
            select_merge: %{ display: d.name, room: r.name },
            order_by: [desc: r.name],
            where: ilike(i.name, ^"%#{search}%")
          )
        {"name", "desc"} ->
        from(i in Item,
          left_join: d in assoc(i, :display),
          left_join: r in assoc(i, :room),
          select: %{ id: i.id, name: i.name },
          select_merge: %{ display: d.name, room: r.name },
          order_by: [desc: i.name],
          where: ilike(i.name, ^"%#{search}%")
        )
      _ ->
        from(i in Item,
          left_join: d in assoc(i, :display),
          left_join: r in assoc(i, :room),
          select: %{ id: i.id, name: i.name },
          select_merge: %{ display: d.name, room: r.name },
          order_by: [asc: i.name],
          where: ilike(i.name, ^"%#{search}%")
        )
    end
    |> Repo.paginate(page: page)
  end

  def list_items(sort, dir, search, user, page) do
    mod_ids = Enum.map(user.active_character.mods, fn m -> m.id end)

    case {sort, dir} do
      {"display", "asc"} ->
        from(i in Item,
          left_join: d in assoc(i, :display),
          left_join: r in assoc(i, :room),
          select: %{ id: i.id, name: i.name },
          select_merge: %{ display: d.name, room: r.name },
          order_by: [asc: d.name],
          where: i.mod_id in ^mod_ids and ilike(i.name, ^"%#{search}%")
        )
      {"display", "desc"} ->
        from(i in Item,
          left_join: d in assoc(i, :display),
          left_join: r in assoc(i, :room),
          select: %{ id: i.id, name: i.name },
          select_merge: %{ display: d.name, room: r.name },
          order_by: [desc: d.name],
          where: i.mod_id in ^mod_ids and ilike(i.name, ^"%#{search}%")
        )
        {"room", "asc"} ->
          from(i in Item,
            left_join: d in assoc(i, :display),
            left_join: r in assoc(i, :room),
            select: %{ id: i.id, name: i.name },
            select_merge: %{ display: d.name, room: r.name },
            order_by: [asc: r.name],
            where: i.mod_id in ^mod_ids and ilike(i.name, ^"%#{search}%")
          )
        {"room", "desc"} ->
          from(i in Item,
            left_join: d in assoc(i, :display),
            left_join: r in assoc(i, :room),
            select: %{ id: i.id, name: i.name },
            select_merge: %{ display: d.name, room: r.name },
            order_by: [desc: r.name],
            where: i.mod_id in ^mod_ids and ilike(i.name, ^"%#{search}%")
          )
        {"name", "desc"} ->
        from(i in Item,
          left_join: d in assoc(i, :display),
          left_join: r in assoc(i, :room),
          select: %{ id: i.id, name: i.name },
          select_merge: %{ display: d.name, room: r.name },
          order_by: [desc: i.name],
          where: i.mod_id in ^mod_ids and ilike(i.name, ^"%#{search}%")
        )
      _ ->
        from(i in Item,
          left_join: d in assoc(i, :display),
          left_join: r in assoc(i, :room),
          select: %{ id: i.id, name: i.name },
          select_merge: %{ display: d.name, room: r.name },
          order_by: [asc: i.name],
          where: i.mod_id in ^mod_ids and ilike(i.name, ^"%#{search}%")
        )
    end
    |> Repo.paginate(page: page)
  end

  def get_item!(id), do: Repo.get!(Item, id)

  def create_item(attrs) do
    %Item{}
    |> Item.changeset(attrs)
    |> Repo.insert()
  end

  # MODS

  def list_mods, do: Repo.all(from(m in Mod, preload: :items ))

  def get_mod_id!(name), do: Repo.one!(from(m in Mod, select: m.id, where: m.name == ^name))

  def create_mod(attrs \\ %{}) do
    %Mod{}
    |> Mod.changeset(attrs)
    |> Repo.insert()
  end
end
