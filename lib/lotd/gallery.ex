defmodule Lotd.Gallery do
  @moduledoc """
  The Gallery context.
  """

  import Ecto.Query, warn: false

  alias Lotd.Repo
  alias Lotd.Gallery.{Display, Item}

  def list_item_ids, do: from(i in Item, select: i.id)

  def item_query() do
    from i in Item,
      order_by: i.id,
      preload: [:display, :quest, :location]
  end

  def list_items, do: Repo.all(Item)

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

  def list_displays, do: Repo.all(Display)

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
