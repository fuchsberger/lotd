defmodule Lotd.Museum.Room do
  use Ecto.Schema

  import Ecto.Changeset

  schema "rooms" do
    field :name, :string
    has_many :items, Lotd.Museum.Item
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, min: 3, max: 80)
    |> unique_constraint(:name)
  end
end
