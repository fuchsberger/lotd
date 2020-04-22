defmodule Lotd.Gallery.Mod do
  use Ecto.Schema
  import Ecto.Changeset

  import Lotd.Repo, only: [validate_url: 2]

  schema "mods" do
    field :name, :string
    field :url, :string
    field :item_count, :integer, virtual: true
    has_many :items, Lotd.Gallery.Item
    many_to_many :characters, Lotd.Accounts.Character, join_through: "character_mods"
  end

  @doc false
  def changeset(mod, attrs) do
    mod
    |> cast(attrs, [:name, :url])
    |> validate_required([:name, :url])
    |> validate_url(:url)
    |> unique_constraint(:name)
    |> unique_constraint(:url)
  end
end
