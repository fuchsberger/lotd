defmodule Lotd.Gallery.Location do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:name, :url]}

  schema "locations" do
    field :name, :string
    field :url, :string
    field :item_count, :integer, virtual: true
    belongs_to :region, Lotd.Gallery.Region
    has_many :items, Lotd.Gallery.Item
  end

  @doc false
  def changeset(mod, attrs) do
    mod
    |> cast(attrs, [:name, :url, :region_id])
    |> validate_required([:name, :region_id])
    |> validate_length(:name, max: 80)
    |> assoc_constraint(:region)
    |> unique_constraint(:name)
  end
end
