defmodule Lotd.Museum.Item do
  use Ecto.Schema

  import Ecto.Changeset
  import Lotd.Repo, only: [validate_url: 2]

  schema "items" do
    field :name, :string
    field :url, :string
    # filed :form_id, :
    belongs_to :display, Lotd.Museum.Display
    belongs_to :location, Lotd.Museum.Location
    belongs_to :mod, Lotd.Museum.Mod
    belongs_to :quest, Lotd.Museum.Quest
    many_to_many :characters, Lotd.Accounts.Character, join_through: "characters_items"
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:name, :url, :display_id, :location_id, :mod_id, :quest_id])
    |> validate_required([:name, :display_id, :mod_id])
    |> validate_length(:name, min: 3, max: 80)
    |> validate_url(:url)
    |> assoc_constraint(:display)
    |> assoc_constraint(:location)
    |> assoc_constraint(:quest)
    |> assoc_constraint(:mod)
    |> unique_constraint(:name)
  end
end
