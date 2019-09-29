defmodule Lotd.Gallery.Display do
  use Ecto.Schema

  import Ecto.Changeset
  import Lotd.Repo, only: [validate_url: 2]

  schema "displays" do
    field :name, :string
    field :url, :string
    has_many :items, Lotd.Gallery.Item
  end

  @doc false
  def changeset(display, attrs) do
    display
    |> cast(attrs, [:name, :url])
    |> validate_required([:name])
    |> validate_length(:name, min: 3, max: 80)
    |> validate_url(:url)
  end
end
