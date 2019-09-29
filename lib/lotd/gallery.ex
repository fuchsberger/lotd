defmodule Lotd.Gallery do
  @moduledoc """
  The Gallery context.
  """

  import Ecto.Query, warn: false
  alias Lotd.Repo

  alias Lotd.Accounts
  alias Lotd.Accounts.Character
  alias Lotd.Gallery.Item

  def list_items, do: Repo.all(Item)

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
end
