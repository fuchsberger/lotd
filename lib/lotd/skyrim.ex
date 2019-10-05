defmodule Lotd.Skyrim do
  @moduledoc """
  The Skyrim context.
  """

  import Ecto.Query, warn: false

  alias Lotd.Repo
  alias Lotd.Gallery.Item
  alias Lotd.Skyrim.{Quest, Location, Mod}

  # quests

  def list_quests do
    Quest
    |> preload(:items)
    |> Repo.alphabetical()
    |> Repo.all()
  end

  def list_quests(mod_ids) do
    mod_ids = mod_ids ++ [1,2,3,4,5]
    Quest
    |> preload(:items)
    |> where([q], q.mod_id in ^mod_ids)
    |> Repo.alphabetical()
    |> Repo.all()
  end

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

  def delete_quest(%Quest{} = quest) do
    Repo.delete(quest)
  end

  def change_quest(%Quest{} = quest) do
    Quest.changeset(quest, %{})
  end

  # locations

  def list_locations do
    Location
    |> preload(:items)
    |> Repo.alphabetical()
    |> Repo.all()
  end

  def list_locations(mod_ids) do
    mod_ids = mod_ids ++ [1,2,3,4,5]
    Location
    |> preload(:items)
    |> where([l], l.mod_id in ^mod_ids)
    |> Repo.alphabetical()
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

  def delete_location(%Location{} = location) do
    Repo.delete(location)
  end

  def change_location(%Location{} = location) do
    Location.changeset(location, %{})
  end

  # mods

  def list_mod_ids, do: from(m in Mod, select: m.id)

  def list_mods do
    item_query = from(i in Item, select: i.id)
    Mod
    |> preload(items: ^item_query)
    |> Repo.alphabetical()
    |> Repo.all()
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

  def delete_mod(%Mod{} = mod) do
    Repo.delete(mod)
  end

  def change_mod(%Mod{} = mod) do
    Mod.changeset(mod, %{})
  end
end
