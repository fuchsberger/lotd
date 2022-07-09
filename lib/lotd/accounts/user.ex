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
    timestamps()
  end

  @doc """
  A user changeset for registration.
  """
  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:id, :avatar_url, :username])
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:avatar_url, :hide_aquired_items, :username])
  end

  def admin_changeset(user, attrs) do
    user
    |> cast(attrs, [:admin, :moderator])
  end
end
