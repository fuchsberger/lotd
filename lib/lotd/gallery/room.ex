defmodule Lotd.Gallery.Room do
  use Ecto.Schema

  import Ecto.Changeset
  import Lotd.Repo, only: [validate_url: 2]

  schema "rooms" do
    field :name, :string
    field :url, :string
    has_many :displays, Lotd.Gallery.Display
  end

  @doc false
  def changeset(display, attrs) do
    display
    |> cast(attrs, [:name, :url])
    |> validate_required([:name])
    |> validate_length(:name, min: 3, max: 30)
    |> validate_url(:url)
    |> unique_constraint(:name)
  end
end
