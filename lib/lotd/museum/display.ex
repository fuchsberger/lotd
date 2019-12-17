defmodule Lotd.Museum.Display do
  use Ecto.Schema

  import Ecto.Changeset
  import Lotd.Repo, only: [validate_url: 2]

  schema "displays" do
    field :name, :string
    field :url, :string
    field :room, :integer
    has_many :items, Lotd.Museum.Item
  end

  @doc false
  def changeset(display, attrs) do
    display
    |> cast(attrs, [:name, :room, :url])
    |> validate_required([:name])
    |> validate_length(:name, min: 3, max: 80)
    |> validate_number(:room, greater_than: 0, less_than_or_equal_to: 12)
    |> validate_url(:url)
    |> unique_constraint(:name)
  end
end
