defmodule Lotd.Accounts do
  @moduledoc """
  The Accounts context.
  """
  import Ecto.Query, warn: false

  alias Lotd.Repo
  alias Lotd.Accounts.{Character, User}
  alias Lotd.Museum.{Item, Mod}

  # user
  def list_users, do: Repo.all(User)

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

  defp user_characters_query(query, %User{id: user_id}) do
    from(c in query, where: c.user_id == ^user_id)
  end

  def list_user_characters(%User{} = user) do
    Character
    |> user_characters_query(user)
    |> Repo.sort_by_id()
    |> preload([items: ^Repo.ids(Item), mods: ^Repo.ids(Mod)])
    |> Repo.all()
  end

  def get_user_character!(user, id) do
    Repo.one!(from(c in Character, where: c.user_id == ^user.id and c.id == ^id))
  end

  def get_active_character(user) do
    user
    |> Repo.preload(:active_character)
    |> Map.get(:active_character)
  end

  def get_character_items(character) do
    character
    |> Repo.preload(:items)
    |> Map.get(:items)
  end

  def get_character_item_ids(character) do
    character
    |> Repo.preload(items: Repo.ids(Item))
    |> Map.get(:items)
  end

  def get_character_mods(character) do
    character
    |> Repo.preload(:mods)
    |> Map.get(:mods)
  end

  def get_character_mod_ids(character) do
    character
    |> Repo.preload(mods: Repo.ids(Mod))
    |> Map.get(:mods)
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

  def load_location_ids(character) do
    query = from i in Item, select: i.location_id, where: not is_nil(i.location_id)

    character
    |> Repo.preload([items: query])
    |> Map.get(:items)
  end

  def update_character_collect_item(%Character{} = character, item) do
    character = Repo.preload(character, :items)

    character
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:items, [ item | character.items ])
    |> Repo.update!()
  end

  def update_character_remove_item(%Character{} = character, item_id) do
    character = Repo.preload(character, :items)

    character
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:items, Enum.reject(character.items, fn i -> i.id == item_id end))
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
    character = Repo.preload(character, :mods)

    character
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:mods, Enum.reject(character.mods, fn m -> m.id == mod_id end))
    |> Repo.update!()
  end

  def delete_character(%Character{} = character), do: Repo.delete(character)
  def change_character(%Character{} = character), do: Character.changeset(character, %{})
end
