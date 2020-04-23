defmodule Lotd.Accounts do
  @moduledoc """
  The Accounts context.
  """
  import Ecto.Query, warn: false

  alias Lotd.Repo
  alias Lotd.Accounts.{Character, User}
  alias Lotd.Gallery.{Item, Mod}

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

  # CHARACTERS -----------------------------------------------------------------------------------

  def list_characters(%User{} = user) do
    from(c in Character,
      left_join: i in assoc(c, :items),
      group_by: c.id,
      select_merge: %{item_count: count(i.id)},
      where: c.user_id == ^user.id,
      order_by: c.name
    )
    |> Repo.all()
  end

  def get_character!(id), do:
    Repo.get!(from(c in Character,
      preload: [ items: ^from(i in Item, select: i.id), mods: ^from(m in Mod, select: m.id)]
    ), id)

  def get_character_mod_ids(%Character{} = character) do
    Repo.all from m in Ecto.assoc(character, :mods), select: m.id
  end

  def get_character_item_ids(%Character{} = character) do
    Repo.all from i in Ecto.assoc(character, :items), select: i.id
  end

  def load_character_items(character), do: Repo.preload(character, :items, force: true)

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
