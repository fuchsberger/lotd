defmodule Lotd.Gallery.Region do
  use Ecto.Schema

  import Ecto.Changeset

  schema "regions" do
    field :name, :string
    field :location_count, :integer, virtual: true
    has_many :locations, Lotd.Gallery.Location
  end

  @doc false
  def changeset(display, attrs) do
    display
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, min: 3, max: 30)
    |> unique_constraint(:name)
  end
end
