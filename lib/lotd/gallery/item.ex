defmodule Lotd.Gallery.Item do
  use Ecto.Schema
  import Ecto.Changeset

  import Lotd.Repo, only: [validate_url: 2]

  schema "items" do
    field :name, :string
    field :url, :string
    many_to_many :characters, Lotd.Accounts.Character, join_through: "characters_items"
    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:name, :url])
    |> validate_required([:name])
    |> validate_length(:name, min: 3, max: 80)
    |> validate_url(:url)
  end
end
