defmodule Lotd.Accounts do
  @moduledoc """
  The Accounts context.
  """
  import Ecto.Query

  alias Lotd.Repo
  alias Lotd.Accounts.{Character, UserToken, User}
  alias Lotd.Gallery.{Item, Mod}

  ## user
  def preload_user_assigns(user) do
    Repo.preload(user, [
      active_character: from(c in Character, preload: [items: ^from(i in Item, select: i.id)]),
      mods: from(m in Mod, select: m.id)
    ])
  end

  def preload_user_associations(user) do
    Repo.preload(user, [
      active_character: from(c in Character, preload: [
          items: ^from(i in Item, select: i.id),
          mods: ^from(m in Mod, select: m.id),
        ]),
      characters: from(c in Character, select: map(c, [:id, :name]), order_by: c.name)
    ], force: true)
  end

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

  def list_user_characters(%User{} = user) do
    from(c in Character, preload: :items, where: c.user_id == ^user.id)
    |> Repo.all()
  end

  def get_character!(id), do: Repo.get!(Character, id)

  def preload_items(%Character{} = character), do: Repo.preload(character, :items)

  def change_character(%Character{} = character, params \\ %{}),
    do: Character.changeset(character, params)

  def create_character(user, params) do
    %Character{}
    |> change_character(params)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert()
  end

  def update_character(character, params) do
    character
    |> change_character(params)
    |> Repo.update()
  end

  def delete_character(%Character{} = character), do: Repo.delete(character)

  # MUSEUM FEATURES

  def refresh_character!(%Character{} = character) do
    now = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)

    character
    |> Ecto.Changeset.change(%{updated_at: now})
    |> Repo.update!()
  end

  def toggle_item!(%Character{} = character, item_id) do
    item = Repo.get(Item, item_id)
    character = Repo.preload(character, :items, force: true)

    if Enum.find(character.items, & &1.id == item.id) do
      character
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_assoc(:items, Enum.reject(character.items, & &1.id == item.id))
      |> Repo.update!()
      false
    else
      character
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_assoc(:items, [item | character.items])
      |> Repo.update!()
      true
    end
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
