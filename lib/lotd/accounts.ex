defmodule Lotd.Accounts do
  @moduledoc """
  The Accounts context.
  """
  import Ecto.Query

  alias Lotd.Repo
  alias Lotd.Accounts.{UserToken, User}
  alias Lotd.Gallery.Mod

  ## user
  def preload_user_assigns(user) do
    Repo.preload(user, [mods: from(m in Mod, select: m.id)])
  end

  def list_users do
    Repo.all from(u in User, order_by: u.name)
  end

  def get_user(id), do: Repo.get(User, id)

  def get_user!(id) do
    from(u in User) |> Repo.get!(id)
  end

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def delete_user(%User{} = user), do: Repo.delete(user)

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Gets the user with the given signed token.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_session_token(token) do
    Repo.delete_all(UserToken.token_and_context_query(token, "session"))
    :ok
  end

  def toggle_mod(%User{} = user, mod_id) do
    mod = Repo.get(Mod, mod_id)
    user = Repo.preload(user, :mods, force: true)

    if Enum.find(user.mods, & &1.id == mod.id) do
      user
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_assoc(:mods, Enum.reject(user.mods, & &1.id == mod.id))
      |> Repo.update()

    else
      user
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_assoc(:mods, [mod | user.mods])
      |> Repo.update()
    end
  end

  def toggle_mods(%User{} = user) do
    mods = Repo.all(Mod)
    user = Repo.preload(user, :mods, force: true)

    if Enum.count(mods) == Enum.count(user.mods) do
      user
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_assoc(:mods, [])
      |> Repo.update()
    else
      user
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_assoc(:mods, mods)
      |> Repo.update()
    end
  end
end
