defmodule Lotd.Skyrim do
  @moduledoc """
  The Skyrim context.
  """

  import Ecto.Query, warn: false

  alias Lotd.{Accounts, Repo}
  alias Lotd.Skyrim.{Quest, Location, Mod}

  # quests

  def list_alphabetical_quests do
    Quest
    |> preload(:items)
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

  def list_alphabetical_locations do
    Location
    |> preload(:items)
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

  def list_alphabetical_mods do
    Mod
    |> preload(:items)
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

  defp mod_ids(%{} = struct) do
    struct
    |> Map.get(:mods)
    |> Enum.map(fn m -> m.id end)
  end

  def activate_mod(character, mod_id) do
    mods = from(m in Mod, where: m.id == ^mod_id or m.id in ^mod_ids(character)) |> Repo.all

    character
    |> Accounts.change_character()
    |> Ecto.Changeset.put_assoc(:mods, mods)
    |> Repo.update!
  end

  def deactivate_mod(character, mod_id) do
    mods = from(m in Mod, where: m.id != ^mod_id and m.id in ^mod_ids(character)) |> Repo.all

    character
    |> Accounts.change_character()
    |> Ecto.Changeset.put_assoc(:mods, mods)
    |> Repo.update!
  end

  def delete_mod(%Mod{} = mod) do
    Repo.delete(mod)
  end

  def change_mod(%Mod{} = mod) do
    Mod.changeset(mod, %{})
  end
end
