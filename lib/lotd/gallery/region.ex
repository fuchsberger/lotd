defmodule Lotd.Gallery.Region do
  use Ecto.Schema

  import Ecto.Changeset
  import Lotd.Repo, only: [validate_url: 2]

  schema "regions" do
    field :name, :string
    field :url, :string
    has_many :locations, Lotd.Gallery.Location
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
