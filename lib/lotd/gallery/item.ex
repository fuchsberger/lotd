defmodule Lotd.Gallery.Item do
  use Ecto.Schema

  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:name, :url, :display_id, :mod_id, :location_id]}
  schema "items" do
    field :name, :string
    field :url, :string

    belongs_to :display, Lotd.Gallery.Display
    belongs_to :location, Lotd.Gallery.Location
    belongs_to :mod, Lotd.Gallery.Mod

    many_to_many :characters, Lotd.Accounts.Character, join_through: "character_items"
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, ~w(name url display_id location_id mod_id)a)
    |> validate_required([:name, :display_id, :mod_id])
    |> validate_length(:name, max: 250)
    |> assoc_constraint(:display)
    |> assoc_constraint(:location)
    |> assoc_constraint(:mod)
  end
end
