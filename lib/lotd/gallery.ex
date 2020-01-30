defmodule Lotd.Gallery do
  @moduledoc """
  The Gallery context.
  """
  import Ecto.Query, warn: false

  alias Lotd.Repo
  alias Lotd.Gallery.{Display, Item, Location, Mod, Room}

  # DISPLAYS -------------------------------------------------------------------------------------
  def list_displays, do: Repo.all from(d in Display, order_by: d.name)

  def get_display!(id), do: Repo.get!(Display, id)

  def change_display(%Display{} = display), do: Display.changeset(display, %{})

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

  # ITEMS ----------------------------------------------------------------------------------------
  def list_items, do: Repo.all from(i in Item, order_by: i.name)
  def list_items(mod_ids),
    do: Repo.all from(i in Item, order_by: i.name, where: i.mod_id in ^mod_ids)

  def get_item!(id), do: Repo.get!(Item, id)

  def change_item(%Item{} = item), do: Item.changeset(item, %{})

  def create_item(attrs \\ %{}) do
    %Item{}
    |> Item.changeset(attrs)
    |> Repo.insert()
  end

  def delete_item(%Item{} = item), do: Repo.delete(item)

  def update_item(%Item{} = item, %{} = attrs) do
    item
    |> Item.changeset(attrs)
    |> Repo.update()
  end

  # LOCATIONS ------------------------------------------------------------------------------------
  def list_locations, do: Repo.all from(r in Location, order_by: r.name)

  def get_location!(id), do: Repo.get!(Location, id)

  def change_location(%Location{} = location), do: Location.changeset(location, %{})

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
  def list_mods, do: Repo.all from(d in Mod, order_by: d.name)
  def list_mods(ids), do: Repo.all from(d in Mod, order_by: d.name, where: d.id in ^ids)

  def get_mod!(id), do: Repo.get!(Mod, id)

  def change_mod(%Mod{} = mod), do: Mod.changeset(mod, %{})

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

  # ROOMS ----------------------------------------------------------------------------------------
  def list_rooms, do: Repo.all from(r in Room, order_by: r.name)

  def get_room!(id), do: Repo.get!(Room, id)

  def change_room(%Room{} = room), do: Room.changeset(room, %{})

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
end
