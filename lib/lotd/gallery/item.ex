defmodule Lotd.Gallery.Item do
  use Ecto.Schema

  import Ecto.Changeset

  schema "items" do
    field :name, :string
    field :url, :string
    field :room_id, :integer, virtual: true

    belongs_to :display, Lotd.Gallery.Display
    belongs_to :mod, Lotd.Gallery.Mod

    many_to_many :characters, Lotd.Accounts.Character, join_through: "character_items"
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, ~w(name url room_id display_id mod_id)a)
    |> validate_required([:name])
    |> validate_length(:name, max: 200)
    |> assoc_constraint(:display)
    |> assoc_constraint(:mod)
  end
end
