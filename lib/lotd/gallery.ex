defmodule Lotd.Gallery do
  @moduledoc """
  The Gallery context.
  """
  import Ecto.Query, warn: false

  alias Lotd.Repo
  alias Lotd.Gallery.{Display, Item, Location, Mod, Room}

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
  def get_room_id!(name) do
    case name do
      "Hall of Heroes" -> 1
      "Armory" -> 2
      "Gallery Library" -> 3
      "Daedric Gallery" -> 4
      "Hall of Lost Empires" -> 4
      "Hall of Oddities" -> 4
      "Dragonborn Hall" -> 5
      "Natural Science" -> 6
      _ -> nil
    end
  end

  # DISPLAYS -------------------------------------------------------------------------------------
  def list_displays, do: Repo.all from(d in Display, order_by: d.name)

  def get_display!(id), do: Repo.get!(Display, id)

  def change_display(attrs), do: Display.changeset(%Display{}, attrs)
  def change_display(%Display{} = display, attrs), do: Display.changeset(display, attrs)

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

  def change_item(attrs), do: Item.changeset(%Item{}, attrs)
  def change_item(%Item{} = item, attrs), do: Item.changeset(item, attrs)

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

  def change_location(attrs), do: Location.changeset(%Location{}, attrs)
  def change_location(%Location{} = location, attrs), do: Location.changeset(location, attrs)

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

  def change_mod(attrs), do: Mod.changeset(%Mod{}, attrs)
  def change_mod(%Mod{} = mod, attrs), do: Mod.changeset(mod, attrs)

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

  def change_room(attrs), do: Room.changeset(%Room{}, attrs)
  def change_room(%Room{} = room, attrs), do: Room.changeset(room, attrs)

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
