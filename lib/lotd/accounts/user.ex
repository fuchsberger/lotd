defmodule Lotd.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :admin, :boolean, default: false
    field :avatar_url, :string
    field :username, :string
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
    |> cast(attrs, [:avatar_url])
  end

  def admin_changeset(user, attrs) do
    user
    |> cast(attrs, [:admin])
  end
end
