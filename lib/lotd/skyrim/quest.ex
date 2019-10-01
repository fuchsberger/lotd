defmodule Lotd.Skyrim.Quest do
  use Ecto.Schema

  import Ecto.Changeset
  import Lotd.Repo, only: [validate_url: 2]

  schema "quests" do
    field :name, :string
    field :url, :string
    has_many :items, Lotd.Gallery.Item
  end

  @doc false
  def changeset(quest, attrs) do
    quest
    |> cast(attrs, [:name, :url])
    |> validate_required([:name])
    |> validate_length(:name, min: 3, max: 80)
    |> validate_url(:url)
    |> unique_constraint(:name)
  end
end
