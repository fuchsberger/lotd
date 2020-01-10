defmodule Lotd.Gallery.Display do
  use Ecto.Schema

  import Ecto.Changeset

  schema "displays" do
    field :name, :string
    has_many :items, Lotd.Gallery.Item
  end

  @doc false
  def changeset(display, attrs) do
    display
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, min: 3, max: 80)
    |> unique_constraint(:name)
  end
end
