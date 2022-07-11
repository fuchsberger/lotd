defmodule Lotd.Gallery.Mod do
  use Ecto.Schema
  import Ecto.Changeset

  schema "mods" do
    field :name, :string
    field :initials, :string
    has_many :items, Lotd.Gallery.Item
    many_to_many :characters, Lotd.Accounts.Character, join_through: "character_mods"
  end

  @doc false
  def changeset(mod, attrs) do
    mod
    |> cast(attrs, [:name, :initials])
    |> validate_required([:name])
    |> validate_length(:initials, min: 2, max: 5)
    |> unique_constraint(:name)
  end
end
