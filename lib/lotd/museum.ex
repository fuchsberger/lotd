defmodule Lotd.Museum do
  @moduledoc """
  The Museum context.
  """
  import Ecto.Query, warn: false

  alias Lotd.Repo
  alias Lotd.Accounts
  alias Lotd.Museum.{Display, Item, Location, Mod, Quest}

  # DISPLAYS

  def list_displays, do: Repo.sort_by_name(Display) |> Repo.all()

  def get_display!(id), do: Repo.get!(Display, id)

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

  def change_display(%Display{} = display), do: Display.changeset(display, %{})

  # ITEMS

  def list_item_ids(character, _search \\ "") do
    mod_ids = if character,
      do: Accounts.get_character_mod_ids(character),
      else: Mod |> Repo.ids() |> Repo.all()

    Repo.all(from(i in Item,
      select: i.id,
      order_by: [i.name],
      where: i.mod_id in ^mod_ids
    ))
  end

  def item_query() do
    from i in Item,
      order_by: i.id,
      preload: [:display, :quest, :location]
  end

  def list_items, do: Repo.all from i in Item

  def list_character_item_ids(character) do
    character
    |> Repo.preload(items: from(i in Item, select: i.id))
    |> Map.get(:items)
  end

  def get_item!(id), do: Repo.get!(Item, id)

  def item_owned?(item, character_id) do
    item = Repo.preload(item, :characters)

    item.characters
    |> Enum.map(fn c -> c.id end)
    |> Enum.member?(character_id)
  end

  def save_item(%Item{} = item, attrs) do
    item
    |> Item.changeset(attrs)
    |> Repo.insert_or_update()
    |> Lotd.broadcast_change(@topic_items, [:item, :saved])
  end

  def delete_item(%Item{} = item), do: Repo.delete(item)

  def change_item(%Item{} = item, params \\ %{}), do: Item.changeset(item, params)

  # LOCATIONS

  def list_locations do
    query = from i in Item, select: i.id
    from(l in Location, preload: [items: ^query])
    |> Repo.all()
  end

  def get_location!(id), do: Repo.get!(Location, id)

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

  def change_location(%Location{} = location), do: Location.changeset(location, %{})

  # MODS

  def list_mod_ids(_search_string), do: Mod |> Repo.ids() |> Repo.all()

  def list_mods() do
    from(m in Mod, preload: [
      items: ^Repo.ids(Item),
      locations: ^Repo.ids(Location),
      quests: ^Repo.ids(Quest)
    ]) |> Repo.all()
  end

  def get_mod!(id), do: Repo.get!(Mod, id)

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

  def change_mod(%Mod{} = mod), do: Mod.changeset(mod, %{})

  # QUESTS

  def list_quests, do: Repo.sort_by_id(Quest) |> Repo.all()

  def get_quest!(id), do: Repo.get!(Quest, id)

  def create_quest(attrs \\ %{}) do
    %Quest{}
    |> Quest.changeset(attrs)
    |> Repo.insert()
  end

  def update_quest(%Quest{} = quest, attrs) do
    quest
    |> Quest.changeset(attrs)
    |> Repo.update()
  end

  def delete_quest(%Quest{} = quest), do: Repo.delete(quest)

  def change_quest(%Quest{} = quest), do: Quest.changeset(quest, %{})
end
