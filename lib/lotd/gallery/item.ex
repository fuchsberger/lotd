defmodule Lotd.Gallery.Item do
  use Ecto.Schema

  import Ecto.Changeset

  schema "items" do
    field :name, :string
    field :url, :string
    field :replica, :boolean, default: false

    belongs_to :display, Lotd.Gallery.Display
    belongs_to :location, Lotd.Gallery.Location
    belongs_to :mod, Lotd.Gallery.Mod

    many_to_many :characters, Lotd.Accounts.Character, join_through: "character_items"
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, ~w(name url replica display_id location_id mod_id)a)
    |> validate_inclusion(:replica, [true, false])
    |> validate_required([:name, :display_id, :mod_id])
    |> validate_length(:name, max: 250)
    |> assoc_constraint(:display)
    |> assoc_constraint(:location)
    |> assoc_constraint(:mod)
  end
end
