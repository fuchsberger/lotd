defmodule Lotd.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :admin, :boolean, default: false
    field :avatar_url, :string
    field :hide_aquired_items, :boolean, default: false
    field :moderator, :boolean, default: false
    field :username, :string

    belongs_to :active_character, Lotd.Accounts.Character
    has_many :characters, Lotd.Accounts.Character
    many_to_many :mods, Lotd.Gallery.Mod, join_through: "user_mods", on_replace: :delete
    timestamps()
  end

  @doc """
  A user changeset for registration.
  """
  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:id, :avatar_url, :username])
    |> validate_required([:id, :username])
    |> unique_constraint(:username)
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:avatar_url, :hide_aquired_items, :active_character_id])
    |> foreign_key_constraint(:active_character_id)

  end

  def admin_changeset(user, attrs) do
    user
    |> cast(attrs, [:admin, :moderator])
  end
end
