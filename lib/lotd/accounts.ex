defmodule Lotd.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Lotd.Repo
  alias Lotd.Accounts.{Character, User}

  # user
  def list_users, do: Repo.all(User)

  def get_user!(id) do
    User
    |> preload(active_character: [ :items, :mods ])
    |> Repo.get!(id)
  end

  def get_user_by(params) do
    User
    |> preload(active_character: [ :items, :mods ])
    |> Repo.get_by(params)
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

  # character

  defp user_characters_query(query, %User{id: user_id}) do
    from(c in query, where: c.user_id == ^user_id)
  end

  def list_user_characters(%User{} = user) do
    Character
    |> user_characters_query(user)
    |> preload(:items)
    |> Repo.all()
  end

  def get_character!(id) do
    from(c in Character, where: c.id == ^id, preload: [:items])
    |> Repo.one!()
  end

  def get_character_items(character) do
    character
    |> Repo.preload(:items)
    |> Map.get(:items)
  end

  def get_character_item_ids(character) do
    character
    |> get_character_items()
    |> Enum.map(fn m -> m.id end)
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

  def update_character_add_item(%Character{} = character, item) do
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

  def delete_character(%Character{} = character), do: Repo.delete(character)
  def change_character(%Character{} = character), do: Character.changeset(character, %{})
end
