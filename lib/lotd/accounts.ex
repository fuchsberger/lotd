defmodule Lotd.Accounts do
  @moduledoc """
  The Accounts context.
  """
  import Ecto.Query, warn: false

  alias Lotd.Repo
  alias Lotd.Accounts.{Character, User}
  alias Lotd.Museum.{Item, Mod}

  # user

  def get_user!(id) do
    User
    |> preload(active_character: [:items, :mods])
    |> Repo.get!(id)
  end

  def get_user_by(params), do: Repo.get_by(User, params)

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

  # character

  def list_characters(%User{} = user) do
    from(c in Character,
      preload: [items: ^Repo.ids(Item), mods: ^Repo.ids(Mod)],
      where: c.user_id == ^user.id
    )
    |> Repo.all()
  end

  def get_character(id), do: Repo.get(Character, id)

  def activate_character(user, character) do
    user
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:active_character, character)
    |> Repo.update!()
  end

  def create_character(%User{} = user, attrs \\ %{}) do
    %Character{}
    |> Character.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert()
  end

  def update_character(%Character{} = character, %{} = attrs) do
    character
    |> Character.changeset(attrs)
    |> Repo.update()
  end

  def update_character_collect_item(%Character{} = character, item) do
    character
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:items, [ item | character.items ])
    |> Repo.update!()
  end

  def update_character_remove_item(%Character{} = character, item_id) do
    character
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:items, Enum.reject(character.items, fn i -> i.id == item_id end))
    |> Repo.update!()
  end

  def update_character_add_mod(%Character{} = character, mod) do
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
  def change_character(%Character{} = character), do: Character.changeset(character, %{})
end
