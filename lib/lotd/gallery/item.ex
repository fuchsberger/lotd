defmodule Lotd.Gallery.Item do
  use Ecto.Schema

  import Ecto.Changeset
  import Lotd.Repo, only: [validate_url: 2]

  schema "items" do
    field :name, :string
    field :url, :string
    belongs_to :display, Lotd.Gallery.Display
    belongs_to :location, Lotd.Skyrim.Location
    belongs_to :quest, Lotd.Skyrim.Quest
    many_to_many :characters, Lotd.Accounts.Character, join_through: "characters_items"
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:name, :url, :display_id, :location_id, :quest_id])
    |> validate_required([:name, :display_id])
    |> validate_length(:name, min: 3, max: 80)
    |> validate_url(:url)
    |> assoc_constraint(:display)
    |> assoc_constraint(:location)
    |> assoc_constraint(:quest)
    |> unique_constraint(:name)
  end
end
