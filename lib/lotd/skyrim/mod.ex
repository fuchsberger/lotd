defmodule Lotd.Skyrim.Mod do
  use Ecto.Schema
  import Ecto.Changeset

  schema "mods" do
    field :filename, :string
    field :name, :string
    field :url, :string
    has_many :items, Lotd.Gallery.Item
    has_many :quests, Lotd.Skyrim.Quest
    has_many :locations, Lotd.Skyrim.Location
    many_to_many :characters, Lotd.Accounts.Character, join_through: "characters_mods"
  end

  @doc false
  def changeset(mod, attrs) do
    mod
    |> cast(attrs, [:name, :url, :filename])
    |> validate_required([:name, :filename])
    |> unique_constraint(:name)
    |> unique_constraint(:url)
    |> unique_constraint(:filename)
  end
end