defmodule Lotd.Accounts.Character do
  use Ecto.Schema
  import Ecto.Changeset

  schema "characters" do
    field :name, :string
    belongs_to :user, Lotd.Accounts.User
    many_to_many :items, Lotd.Museum.Item, join_through: "characters_items", on_replace: :delete
    many_to_many :mods, Lotd.Museum.Mod, join_through: "characters_mods", on_replace: :delete
    timestamps()
  end

  @doc false
  def changeset(character, attrs) do
    character
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, min: 3, max: 80)
  end
end
