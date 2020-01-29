defmodule Lotd.Gallery.Location do
  use Ecto.Schema
  import Ecto.Changeset

  schema "locations" do
    field :name, :string
    has_many :items, Lotd.Gallery.Item
  end

  @doc false
  def changeset(mod, attrs) do
    mod
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
