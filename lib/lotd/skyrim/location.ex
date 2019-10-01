defmodule Lotd.Skyrim.Location do
  use Ecto.Schema
  import Ecto.Changeset

  schema "locations" do
    field :name, :string
    field :url, :string
    has_many :items, Lotd.Gallery.Item
  end

  @doc false
  def changeset(location, attrs) do
    location
    |> cast(attrs, [:name, :url])
    |> validate_required([:name])
  end
end
