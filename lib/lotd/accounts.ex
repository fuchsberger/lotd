defmodule Lotd.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Lotd.Repo

  alias Lotd.Accounts.User
  alias Lotd.Accounts.Character

  # user
  def list_users, do: Repo.all(User)

  def get_user!(id) do
    User
    |> preload(active_character: [:items])
    |> Repo.get!(id)
  end

  def get_user_by(params) do
    User
    |> preload(:active_character)
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
  def list_user_characters(%User{} = user) do
    Character
    |> user_characters_query(user)
    |> preload(:items)
    |> Repo.all()
  end

  def get_character!(id) do
    from(c in Character, where: c.id == ^id, preload: [:items])
    |> Repo.one()
  end

  def get_user_character!(%User{} = user, id) do
    Character
    |> user_characters_query(user)
    |> Repo.get!(id)
  end

  def character_item_ids(character) do
    character
    |> Map.get(:items)
    |> Enum.map(fn i -> i.id end)
  end

  defp user_characters_query(query, %User{id: user_id}) do
    from(c in query, where: c.user_id == ^user_id)
  end

  def create_character(%User{} = user, attrs \\ %{}) do
    %Character{}
    |> Character.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert()
  end

  def update_character(%Character{} = character, attrs) do
    character
    |> Character.changeset(attrs)
    |> Repo.update()
  end

  def delete_character(%Character{} = character), do: Repo.delete(character)
  def change_character(%Character{} = character), do: Character.changeset(character, %{})

  def activate_character(user, %Character{} = character) do
    if character.user_id == user.id do
      update_user(user, %{ active_character_id: character.id })
    else
      { :error, "You cannot activate another user's character." }
    end
  end
end
