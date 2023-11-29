defmodule Lotd.Gallery.Region do
  use Ecto.Schema

  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:name]}
  schema "regions" do
    field :name, :string
    has_many :locations, Lotd.Gallery.Location
  end

  @doc false
  def changeset(region, attrs) do
    region
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, min: 3, max: 30)
    |> unique_constraint(:name)
  end
end
