defmodule Lotd.Gallery.Item do
  use Ecto.Schema

  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:name, :url, :mod_id, :location_id]}
  schema "items" do
    field :name, :string
    field :url, :string

    belongs_to :location, Lotd.Gallery.Location
    belongs_to :mod, Lotd.Gallery.Mod
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, ~w(name url location_id mod_id)a)
    |> validate_required([:name, :location_id, :mod_id])
    |> validate_length(:name, max: 80)
    |> assoc_constraint(:location)
    |> assoc_constraint(:mod)
  end
end
