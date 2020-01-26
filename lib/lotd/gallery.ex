defmodule Lotd.Gallery do
  @moduledoc """
  The Gallery context.
  """
  import Ecto.Query, warn: false

  alias Lotd.Repo
  alias Lotd.Gallery.{Display, Item, Mod, Room}

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

  # DISPLAYS

  def list_displays, do: Repo.all from(d in Display, order_by: d.name)

  def get_display_id!(name),
    do: Repo.one!(from(d in Display, select: d.id, where: d.name == ^name))

  def create_display(attrs) do
    %Display{}
    |> Display.changeset(attrs)
    |> Repo.insert()
  end

  # ITEMS
  def list_items, do: Repo.all(from(i in Item, order_by: i.name))
  def list_items(nil), do: Repo.all(from(i in Item, order_by: i.name, preload: :display))

  def list_items(user), do: Repo.all(from(i in Item,
    order_by: i.name,
    preload: :display,
    where: i.mod_id in ^user.active_character.mods
  ))

  # def change_item(%Item{} = item, params \\ %{}), do: Item.changeset(character, params)

  def get_item!(id), do: Repo.get!(Item, id)

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

  def change_item(%Item{} = item, attrs), do: Item.changeset(item, attrs)

  # MODS

  def list_mods, do: Repo.all(from(m in Mod, order_by: m.name, preload: [items: ^Repo.ids(Item)]))

  def get_mod(id), do: Repo.get(Mod, id)

  def get_mod_id!(name), do: Repo.one!(from(m in Mod, select: m.id, where: m.name == ^name))

  def create_mod(attrs \\ %{}) do
    %Mod{}
    |> Mod.changeset(attrs)
    |> Repo.insert()
  end

  # ROOMS
  def list_rooms, do: Repo.all from(r in Room, order_by: r.name)

  def change_room(attrs), do: Room.changeset(%Room{}, attrs)
  def change_room(%Room{} = room, attrs), do: Room.changeset(room, attrs)

  def create_room(name), do: Repo.insert!(%Room{name: name}, on_conflict: :nothing)

end
