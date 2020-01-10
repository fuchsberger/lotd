defmodule Lotd.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :admin, :boolean, default: false
    field :moderator, :boolean, default: false
    belongs_to :active_character, Lotd.Accounts.Character
    has_many :characters, Lotd.Accounts.Character
    timestamps()
  end

  @doc false
  def register_changeset(user, attrs) do
    user
    |> cast(attrs, [:id, :name])
    |> validate_required([:id, :name])
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:admin, :moderator, :active_character_id])
    |> assoc_constraint(:active_character)
  end
end
