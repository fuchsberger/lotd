defmodule Lotd.Gallery.ItemFilter do
  use Ecto.Schema

  import Ecto.Changeset

  embedded_schema do
    field :name, :integer
    belongs_to :display, Lotd.Gallery.Display
    belongs_to :location, Lotd.Gallery.Location
    belongs_to :region, Lotd.Gallery.Region
    belongs_to :room, Lotd.Gallery.Room
    belongs_to :mod, Lotd.Gallery.Mod
  end

  @doc false
  def changeset(item_filter, attrs) do
    item_filter
    |> cast(attrs, ~w(name display_id location_id mod_id region_id room_id)a)
    |> validate_length(:name, max: 80)
  end
end
