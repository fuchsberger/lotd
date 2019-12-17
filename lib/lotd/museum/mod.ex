defmodule Lotd.Museum.Mod do
  use Ecto.Schema
  import Ecto.Changeset

  schema "mods" do
    field :filename, :string
    field :name, :string
    field :url, :string
    has_many :items, Lotd.Museum.Item
    has_many :quests, Lotd.Museum.Quest
    has_many :locations, Lotd.Museum.Location
    many_to_many :characters, Lotd.Accounts.Character, join_through: "characters_mods"
  end

  @doc false
  def changeset(mod, attrs) do
    mod
    |> cast(attrs, [:name, :url, :filename])
    |> validate_required([:name])
    |> unique_constraint(:name)
    |> unique_constraint(:url)
    |> unique_constraint(:filename)
  end
end
