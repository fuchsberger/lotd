defmodule Lotd.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Lotd.{Repo, Gallery, Skyrim}
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

  # activating / deactivating mods, collecting / borrowing items
  def update_character(%Character{} = character, association, collection) do
    character
    |> change_character()
    |> Ecto.Changeset.put_assoc(association, collection)
    |> Repo.update()
  end

  def delete_character(%Character{} = character), do: Repo.delete(character)
  def change_character(%Character{} = character), do: Character.changeset(character, %{})
end
