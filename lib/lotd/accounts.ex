defmodule Lotd.Accounts do
  @moduledoc """
  The Accounts context.
  """
  import Ecto.Query

  alias Lotd.Repo
  alias Lotd.Accounts.{Character, UserToken, User}
  alias Lotd.Gallery.{Item, Mod}

  ## shared

  def preload_characters_query do
    from c in Character,
      preload: [items: ^from(m in Item, select: m.id), mods: ^from(m in Mod, select: m.id)],
      order_by: c.name
  end

  def preload(struct, preloads, opts \\ []) do
    Repo.preload(struct, preloads, opts)
  end

  # user
  def list_users do
    Repo.all from(u in User, preload: [characters: [:items]], order_by: u.name)
  end

  def get_user(id), do: Repo.get(User, id)

  def get_user!(id) do
    subquery = from(c in Character,
      preload: [items: ^from(m in Item, select: m.id), mods: ^from(m in Mod, select: m.id)],
      order_by: c.name
    )
    from(u in User, preload: [:active_character, characters: ^subquery]) |> Repo.get!(id)
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

  def activate_mod(%Character{} = character, %Mod{} = mod) do
    character = Repo.preload(character, :mods, force: true)
    character_mods = [mod | character.mods]

    character
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:mods, character_mods)
    |> Repo.update()
  end

  def deactivate_mod(%Character{} = character, %Mod{} = mod) do
    character = Repo.preload(character, :mods, force: true)
    character_mods = Enum.reject(character.mods, & &1.id == mod.id)

    character
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:mods, character_mods)
    |> Repo.update()
  end
end
