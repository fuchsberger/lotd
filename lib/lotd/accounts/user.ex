defmodule Lotd.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    many_to_many :mods, Lotd.Gallery.Mod, join_through: "user_mods", on_replace: :delete
    timestamps(updated_at: false)
  end

  @doc """
  A user changeset for registration.
  """
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:id])
    |> validate_required([:id])
  end
end
