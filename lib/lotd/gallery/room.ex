defmodule Lotd.Gallery.Room do
  use Ecto.Schema

  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:name]}
  schema "rooms" do
    field :name, :string
    has_many :displays, Lotd.Gallery.Display
  end

  @doc false
  def changeset(display, attrs) do
    display
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, min: 3, max: 30)
    |> unique_constraint(:name)
  end
end
