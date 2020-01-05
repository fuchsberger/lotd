defmodule Lotd.Museum.Mod do
  use Ecto.Schema
  import Ecto.Changeset

  schema "mods" do
    field :name, :string
    has_many :items, Lotd.Museum.Item
    many_to_many :characters, Lotd.Accounts.Character, join_through: "character_mods"
  end

  @doc false
  def changeset(mod, attrs) do
    mod
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
