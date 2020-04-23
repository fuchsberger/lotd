defmodule Lotd.Gallery.Item do
  use Ecto.Schema

  import Ecto.Changeset

  schema "items" do
    field :name, :string
    field :url, :string
    field :replica, :boolean, default: false
    field :display_name, :string, virtual: true
    field :location_name, :string, virtual: true
    field :mod_name, :string, virtual: true

    belongs_to :display, Lotd.Gallery.Display
    belongs_to :location, Lotd.Gallery.Location
    belongs_to :mod, Lotd.Gallery.Mod

    many_to_many :characters, Lotd.Accounts.Character, join_through: "character_items"
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, ~w(name url replica display_id display_name location_id location_name mod_id mod_name)a)
    |> validate_inclusion(:replica, [true, false])
    |> validate_required([:name, :display_id, :display_name, :mod_id, :mod_name])
    |> validate_length(:name, max: 250)
    |> assoc_constraint(:display)
    |> assoc_constraint(:location)
    |> assoc_constraint(:mod)
  end
end
