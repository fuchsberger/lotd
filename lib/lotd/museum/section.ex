defmodule Lotd.Museum.Section do
  use Ecto.Schema

  import Ecto.Changeset
  import Lotd.Repo, only: [validate_url: 2]

  # rooms: (1) Hall of Heroes, (2) Gallery Library, (3) Daedric Gallery, (4) Hall of Lost Empires, (5) Hall of Oddities, (6) Natural Science, (7) Dragonborn Hall, (8) Armory, (9) Hall of Secrets, (10) Museum Storeroom, (11) Safehouse, (12) Guildhouse

  schema "sections" do
    field :name, :string
    field :url, :string
    field :room, :integer
    has_many :items, Lotd.Museum.Item
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
