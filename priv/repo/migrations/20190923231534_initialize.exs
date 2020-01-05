defmodule Lotd.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do

    # create users
    create table(:users) do
      add :nexus_id, :integer, null: false
      add :nexus_name, :string, null: false
      add :admin, :boolean, default: false, null: false
      add :moderator, :boolean, default: false, null: false
      timestamps()
    end
    create unique_index(:users, [:nexus_id])

    # create characters
    create table(:characters) do
      add :name, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      timestamps()
    end
    create index(:characters, [:user_id])

    # link users and characters
    alter table(:users) do
      add :active_character_id, references(:characters, on_delete: :nilify_all)
    end
    create index(:users, [:active_character_id])

    # create rooms
    create table(:rooms) do
      add :name, :string, null: false
    end
    create unique_index(:rooms, [:name])

    # create displays
    create table(:displays) do
      add :name, :string, null: false
    end

    # create items
    create table(:items) do
      add :name, :string, null: false
      add :form_id, :string, null: false
      add :replica_id, :string
      add :display_ref, :string
    end
    create unique_index(:items, [:name])
    create unique_index(:items, [:form_id])
    create unique_index(:items, [:replica_id])

    # create mods
    create table(:mods) do
      add :name, :string
    end
    create unique_index(:mods, [:name])

    # link items and displays (n:m)
    create table(:character_items) do
      add :character_id, references(:characters, on_delete: :delete_all), null: false
      add :item_id, references(:items, on_delete: :delete_all), null: false
    end
    create unique_index(:character_items, [:character_id, :item_id])

    # link characters and mods (n:m)
    create table(:characters_mods) do
      add :character_id, references(:characters, on_delete: :delete_all), null: false
      add :mod_id, references(:mods, on_delete: :delete_all), null: false
    end

    create unique_index(:characters_mods, [:character_id, :mod_id])

    # create foreign keys
    alter table(:items) do
      add :display_id, references(:displays, on_delete: :delete_all), null: false
      add :mod_id, references(:mods, on_delete: :delete_all), null: false
      add :room_id, references(:rooms, on_delete: :delete_all), null: false
    end

    # create foreign key constraints
    create index(:items, [:display_id])
    create index(:items, [:mod_id])
    create index(:items, [:room_id])
  end
end
