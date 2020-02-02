defmodule Lotd.Accounts do
  @moduledoc """
  The Accounts context.
  """
  import Ecto.Query, warn: false

  alias Lotd.Repo
  alias Lotd.Accounts.{Character, User}
  alias Lotd.Gallery.{Item, Mod}

  # user
  def list_users, do: Repo.all from(u in User, order_by: u.name)

  def get_user(id), do: Repo.get(User, id)

  def get_user!(id) do
    User
    |> preload(active_character: [
        items: ^from(i in Item, select: i.id),
        mods: ^from(m in Mod, select: m.id)
      ])
    |> Repo.get!(id)
  end

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

  def list_characters(%User{} = user) do
    from(c in Character, preload: [:items, :mods], where: c.user_id == ^user.id, order_by: c.name)
    |> Repo.all()
  end

  def get_character(id), do: Repo.get(Character, id)
  def get_character!(id), do: from(c in Character, preload: :items) |> Repo.get!(id)

  def change_character(%Character{} = character), do: Character.changeset(character, %{})

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

  def delete_character(%Character{} = character), do: Repo.delete(character)

  # MUSEUM FEATURES

  def collect_item(character, item) do
    character
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:items, [ item | character.items ])
    |> Repo.update()
  end

  def remove_item(character, item) do
    character
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:items, Enum.reject(character.items, & &1.id == item.id))
    |> Repo.update()
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
    |> Ecto.Changeset.put_assoc(:mods, Enum.reject(character.mods, & &1.id == mod_id))
    |> Repo.update!()
  end
end
