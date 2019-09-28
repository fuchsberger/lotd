defmodule Lotd.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :nexus_id, :integer
    field :nexus_name, :string
    field :admin, :boolean, default: false
    field :moderator, :boolean, default: false
    belongs_to :active_character, Lotd.Accounts.Character
    has_many :characters, Lotd.Accounts.Character
    timestamps()
  end

  @doc false
  def register_changeset(user, attrs) do
    user
    |> cast(attrs, [:nexus_id, :nexus_name])
    |> validate_required([:nexus_id, :nexus_name])
    |> unique_constraint(:nexus_id)
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:admin, :moderator, :active_character_id])
  end
end
