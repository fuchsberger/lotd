defmodule Lotd.Account.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :nexus_id, :integer
    field :nexus_name, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:nexus_id, :nexus_name])
    |> validate_required([:nexus_id, :nexus_name])
    |> unique_constraint(:nexus_id)
  end
end
