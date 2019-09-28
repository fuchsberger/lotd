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
  def get_user(id), do: Repo.get(User, id)
  def get_user!(id), do: Repo.get!(User, id)
  def get_user_by(params), do: Repo.get_by(User, params)

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.register_changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user), do: Repo.delete(user)
  def change_user(%User{} = user), do: User.changeset(user, %{})

  # character
  def list_characters, do: Repo.all(Character)
  def get_character!(id), do: Repo.get!(Character, id)

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
end
