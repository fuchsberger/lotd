defmodule Lotd.Museum.Item do
  use Ecto.Schema

  import Ecto.Changeset

  schema "items" do
    field :name, :string
    field :form_id, :string
    field :replica_id, :string
    field :display_ref, :string

    field :display_name, :string, virtual: true
    field :room_name, :string, virtual: true

    belongs_to :display, Lotd.Museum.Display
    belongs_to :mod, Lotd.Museum.Mod
    belongs_to :room, Lotd.Museum.Room

    many_to_many :characters, Lotd.Accounts.Character, join_through: "characters_items"
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:name, :form_id, :replica_id, :display_id, :display_id, :mod_id, :room_id])
    |> validate_required([:name, :display_id, :mod_id, :form_id, :room_id])
    |> validate_length(:name, min: 3, max: 80)
    |> validate_length(:form_id, is: 8)
    |> validate_length(:replica_id, is: 8)
    |> validate_length(:display_ref, is: 8)
    |> assoc_constraint(:display)
    |> assoc_constraint(:mod)
    |> assoc_constraint(:room)
    |> unique_constraint(:name)
    |> unique_constraint(:form_id)
    |> unique_constraint(:replica_id)
  end
end
