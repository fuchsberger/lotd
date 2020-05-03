defmodule Lotd.Gallery.Display do
  use Ecto.Schema

  import Ecto.Changeset

  schema "displays" do
    field :name, :string
    belongs_to :room, Lotd.Gallery.Room
    has_many :items, Lotd.Gallery.Item
  end

  @doc false
  def changeset(display, attrs) do
    display
    |> cast(attrs, [:name, :room_id])
    |> validate_required([:name, :room_id])
    |> validate_length(:name, min: 3, max: 40)
    |> assoc_constraint(:room)
    |> unique_constraint(:name)
  end
end
