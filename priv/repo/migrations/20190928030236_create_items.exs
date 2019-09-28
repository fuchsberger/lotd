defmodule Lotd.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do

    # user can activate a character
    alter table(:users) do
      add :active_character_id, references(:characters)
    end
    create index(:users, [:active_character_id])

    # items
    create table(:items) do
      add :name, :string, null: false
      add :url, :string
      timestamps()
    end

    # character_items (many to many)
    create table(:characters_items) do
      add :character_id, references(:characters, on_delete: :delete_all), null: false
      add :item_id, references(:items, on_delete: :delete_all), null: false
    end
    create unique_index(:characters_items, [:character_id, :item_id])
  end
end
