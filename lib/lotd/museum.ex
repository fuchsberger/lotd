defmodule Lotd.Museum do
  @moduledoc """
  The Museum context.
  """
  import Ecto.Query, warn: false

  alias Lotd.Repo
  alias Lotd.Accounts
  alias Lotd.Museum.{Display, Item, Mod}

  # ROOMS
  def get_room(number) do
    case number do
      1 -> "Hall of Heroes"
      2 -> "Library"
      3 -> "Daedric Gallery"
      4 -> "Hall of Lost Empires"
      5 -> "Hall of Oddities"
      6 -> "Natural Science"
      7 -> "Dragonborn Hall"
      8 -> "Armory"
      9 -> "Hall of Secrets"
      10 -> "Museum Storeroom"
      11 -> "Safehouse"
      12 -> "Guildhouse"
      nil -> "Unassigned"
    end
  end

  def get_room_number(room) do
    case room do
      "Hall of Heroes" -> 1
      "Gallery Library" -> 2
      "Daedric Gallery" -> 3
      "Hall of Lost Empires" -> 4
      "Hall of Oddities" -> 5
      "Natural Science" -> 6
      "Dragonborn Hall" -> 7
      "Armory" -> 8
      "Hall of Secrets" -> 9
      "Museum Storeroom" -> 10
      "Safehouse" -> 11
      "Guildhouse" -> 12
      _other -> nil
    end
  end

  def get_form_id(id_string) do
    if id_string == "None" do
      nil
    else
      [_head, tail ] = String.split(id_string, "(")
      [id, _tail ] = String.split(tail, ")")
      id
    end
  end

  # DISPLAYS

  def list_displays, do: Repo.all Repo.sort_by_name(Display)

  def get_display_id!(name),
    do: Repo.one!(from(d in Display, select: d.id, where: d.name == ^name))

  def create_display(attrs) do
    %Display{}
    |> Display.changeset(attrs)
    |> Repo.insert()
  end

  # ITEMS

  def list_items(user) when is_nil(user), do: Repo.all from(i in Item, preload: :display)

  def list_items(user) do
    mod_ids = Enum.map(user.active_character.mods, & &1.id)
    Repo.all from(i in Item, preload: :display, where: i.mod_id in ^mod_ids)
  end

  def create_item(attrs) do
    %Item{}
    |> Item.changeset(attrs)
    |> Repo.insert()
  end

  # MODS

  def list_mods, do: Repo.all from(m in Mod, preload: [ items: ^Repo.ids(Item) ])

  def get_mod_id!(name), do: Repo.one!(from(m in Mod, select: m.id, where: m.name == ^name))

  def create_mod(attrs \\ %{}) do
    %Mod{}
    |> Mod.changeset(attrs)
    |> Repo.insert()
  end
end
