defmodule Lotd.Accounts.Character do
  use Ecto.Schema
  import Ecto.Changeset

  schema "characters" do
    field :name, :string
    field :item_count, :integer, virtual: true

    belongs_to :user, Lotd.Accounts.User
    many_to_many :items, Lotd.Gallery.Item, join_through: "character_items", on_replace: :delete
    many_to_many :mods, Lotd.Gallery.Mod, join_through: "character_mods", on_replace: :delete
    timestamps()
  end

  @doc false
  def changeset(character, attrs) do
    character
    |> cast(attrs, [:name, :user_id])
    |> validate_required([:name])
    |> validate_length(:name, min: 3, max: 80)
    |> assoc_constraint(:user)
  end
end
