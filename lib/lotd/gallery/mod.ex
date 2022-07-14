defmodule Lotd.Gallery.Mod do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:name, :url]}
  schema "mods" do
    field :name, :string
    field :url, :string
    has_many :items, Lotd.Gallery.Item
    many_to_many :users, Lotd.Accounts.User, join_through: "user_mods"
  end

  @doc false
  def changeset(mod, attrs) do
    mod
    |> cast(attrs, [:name, :url])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
