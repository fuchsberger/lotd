defmodule Lotd.Gallery do
  @moduledoc """
  The Gallery context.
  """

  import Ecto.Query, warn: false
  alias Lotd.Repo

  alias Lotd.Accounts
  alias Lotd.Gallery.{Display, Item}

  def alphabetical(query), do: from(c in query, order_by: c.name)

  def list_items, do: from(i in Item, preload: :display) |> Repo.all()

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

  def collect_item(character, item_id) do
    items = from(i in Item,
      where: i.id == ^item_id or i.id in ^Accounts.character_item_ids(character)
    ) |> Repo.all

    character
    |> Accounts.change_character()
    |> Ecto.Changeset.put_assoc(:items, items)
    |> Repo.update!
  end

  def borrow_item(character, item_id) do
    items = from(i in Item,
      where: i.id != ^item_id and i.id in ^Accounts.character_item_ids(character)
    ) |> Repo.all

    character
    |> Accounts.change_character()
    |> Ecto.Changeset.put_assoc(:items, items)
    |> Repo.update!
  end

  def list_alphabetical_displays do
    Display
    |> alphabetical()
    |> Repo.all()
  end

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
