defmodule Lotd.Gallery.Location do
  use Ecto.Schema
  import Ecto.Changeset

  schema "locations" do
    field :name, :string
    field :region_name, :string, virtual: true
    field :item_count, :integer, virtual: true
    belongs_to :region, Lotd.Gallery.Region
    has_many :items, Lotd.Gallery.Item
  end

  @doc false
  def changeset(mod, attrs) do
    mod
    |> cast(attrs, [:name, :region_id])
    |> validate_required([:name, :region_id])
    |> validate_length(:name, max: 80)
    |> assoc_constraint(:region)
    |> unique_constraint(:name)
  end
end
