defmodule Lotd.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do

    # create users and characters
    create table(:users) do
      add :nexus_id, :integer, null: false
      add :nexus_name, :string, null: false
      add :admin, :boolean, default: false, null: false
      add :moderator, :boolean, default: false, null: false
      timestamps()
    end

    create unique_index(:users, [:nexus_id])

    create table(:characters) do
      add :name, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      timestamps()
    end
    create index(:characters, [:user_id])

    # link users and characters
    alter table(:users) do
      add :active_character_id, references(:characters)
    end
    create index(:users, [:active_character_id])

    # create items and displays
    create table(:displays) do
      add :name, :string, null: false
      add :url, :string
    end

    create table(:items) do
      add :name, :string, null: false
      add :url, :string
      add :display_id, references(:displays, on_delete: :delete_all), null: false
    end

    create index(:items, [:display_id])

    # link items and displays
    create table(:characters_items) do
      add :character_id, references(:characters, on_delete: :delete_all), null: false
      add :item_id, references(:items, on_delete: :delete_all), null: false
    end

    create unique_index(:characters_items, [:character_id, :item_id])
  end
end
