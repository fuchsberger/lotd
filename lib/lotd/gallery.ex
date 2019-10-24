defmodule Lotd.Gallery do
  @moduledoc """
  The Gallery context.
  """

  import Ecto.Query, warn: false

  alias Lotd.Repo
  alias Lotd.Accounts.Character
  alias Lotd.Gallery.{Display, Item}
  alias Lotd.Skyrim.{Location, Mod, Quest}

  def list_item_ids, do: from(i in Item, select: i.id)

  def item_query() do
    from i in Item,
      order_by: i.id,
      preload: [:display, :quest, :location]
  end

  defp name_query(struct), do: from(e in struct, select: e.name)

  def list_items do
    character_query = from c in Character, select: c.id
    display_query = from d in Display, select: d.name
    location_query = from l in Location, select: l.name
    mod_query = from m in Mod, select: m.name
    quest_query = from q in Quest, select: q.name

    Repo.all from i in Item, preload: [
      characters: ^character_query,
      display: ^display_query,
      location: ^location_query,
      mod: ^mod_query,
      quest: ^quest_query
    ]
  end

  def list_character_item_ids(character) do
    character
    |> Repo.preload(items: from(i in Item, select: i.id))
    |> Map.get(:items)
  end

  def get_item!(id), do: Repo.get!(Item, id)

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

  def delete_item(%Item{} = item) do
    Repo.delete(item)
  end

  def change_item(%Item{} = item) do
    Item.changeset(item, %{})
  end

  def list_displays, do: Repo.sort_by_id(Display) |> Repo.all()

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

  def delete_display(%Display{} = display) do
    Repo.delete(display)
  end

  def change_display(%Display{} = display) do
    Display.changeset(display, %{})
  end
end
