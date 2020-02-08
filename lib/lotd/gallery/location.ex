defmodule Lotd.Gallery.Location do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:name, :url]}

  schema "locations" do
    field :name, :string
    field :url, :string
    has_many :items, Lotd.Gallery.Item
  end

  @doc false
  def changeset(mod, attrs) do
    mod
    |> cast(attrs, [:name, :url])
    |> validate_required([:name])
    |> validate_length(:name, max: 80)
    |> unique_constraint(:name)
  end
end
