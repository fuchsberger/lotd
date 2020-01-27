defmodule Lotd.Accounts do
  @moduledoc """
  The Accounts context.
  """
  import Ecto.Query, warn: false

  alias Lotd.Repo
  alias Lotd.Accounts.{Character, User}
  alias Lotd.Gallery.{Mod}

  # user
  def get_user(id), do: Repo.get(User, id)

  def get_user!(id) do
    User
    |> preload(active_character: [:items, mods: ^Repo.ids(Mod)])
    |> Repo.get!(id)
  end

  def register_user(attrs \\ %{}) do
    %User{}
    |> User.register_changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  # CHARACTERS -----------------------------------------------------------------------------------

  def delete_mod(%Mod{} = mod), do: Repo.delete(mod)

  def list_characters(%User{} = user) do
    from(c in Character, preload: [:items, :mods], where: c.user_id == ^user.id, order_by: c.name)
    |> Repo.all()
  end

  def get_character(id), do: Repo.get(Character, id)
  def get_character!(id), do: Repo.get!(Character, id)

  def change_character(attrs), do: Character.changeset(%Character{}, attrs)
  def change_character(%Character{} = character, attrs), do: Character.changeset(character, attrs)

  def create_character(attrs \\ %{}) do
    %Character{}
    |> Character.changeset(attrs)
    |> Repo.insert()
  end

  def update_character(%Character{} = character, attrs) do
    character
    |> Character.changeset(attrs)
    |> Repo.update()
  end

  def activate_character(user, character_id) do
    user
    |> Ecto.Changeset.change(%{ active_character_id: character_id})
    |> Repo.update!()
  end

  # MUSEUM FEATURES

  def collect_item(character, item) do
    character
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:items, [ item | character.items ])
    |> Repo.update!()
  end

  def remove_item(character, item) do
    character
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:items, Enum.reject(character.items, fn i -> i.id == item.id end))
    |> Repo.update!()
  end

  def update_character_add_mod(%Character{} = character, mod) do
    character = Repo.preload(character, :mods)

    character
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:mods, [ mod | character.mods ])
    |> Repo.update!()
  end

  def update_character_remove_mod(%Character{} = character, mod_id) do
    character
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:mods, Enum.reject(character.mods, fn m -> m.id == mod_id end))
    |> Repo.update!()
  end

  def delete_character(%Character{} = character), do: Repo.delete(character)
  def change_character(%Character{} = character \\ %Character{}, params \\ %{}),
    do: Character.changeset(character, params)
end
