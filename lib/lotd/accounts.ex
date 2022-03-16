defmodule Lotd.Accounts do
  @moduledoc """
  The Accounts context.
  """
  import Ecto.Query, warn: false

  alias Lotd.Repo
  alias Lotd.Accounts.{Character, User}

  # user
  def list_users do
    Repo.all from(u in User, preload: [characters: [:items]], order_by: u.name)
  end

  def get_user(id), do: Repo.get(User, id)

  def get_user!(id), do: Repo.get!(from(u in User, preload: :active_character), id)

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  # CHARACTERS -----------------------------------------------------------------------------------

  def change_character(%Character{} = character, params \\ %{}),
    do: Character.changeset(character, params)

  def delete_character(%Character{} = character), do: Repo.delete(character)

  # MUSEUM FEATURES

  def collect_item(%Character{} = character, item) do
    character = Repo.preload(character, :items, force: true)

    character
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:items, [ item | character.items ])
    |> Repo.update!()
  end

  def remove_item(%Character{} = character, item) do
    character = Repo.preload(character, :items, force: true)

    character
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:items, Enum.reject(character.items, & &1.id == item.id))
    |> Repo.update!()
  end

  def toggle_character_mod(%Character{} = character, mod) do
    character = Repo.preload(character, :mods)

    case Enum.find(character.mods, & &1.id == mod.id) do
      nil ->
        character
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.put_assoc(:mods, [mod | character.mods])
        |> Repo.update!()

      mod ->
        character
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.put_assoc(:mods, Enum.reject(character.mods, & &1.id == mod.id))
        |> Repo.update!()
    end
    |> Map.get(:mods)
    |> Enum.map(& &1.id)
  end
end
