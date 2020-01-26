defmodule Lotd.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do

    # create users
    create table(:users) do
      add :name, :string, null: false
      add :admin, :boolean, null: false
      add :moderator, :boolean, null: false
      timestamps()
    end

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

    # create rooms
    create table(:rooms) do
      add :name, :string, null: false
    end
    create unique_index(:rooms, [:name])

    # create displays
    create table(:displays) do
      add :name, :string, null: false
      add :room_id, references(:rooms, on_delete: :nilify_all)
    end
    create index(:displays, [:room_id])

    # create mods
    create table(:mods) do
      add :name, :string
    end
    create unique_index(:mods, [:name])

    # create items
    create table(:items) do
      add :name, :string, null: false
      add :url, :string
      add :display_id, references(:displays, on_delete: :nilify_all), null: false
      add :mod_id, references(:mods, on_delete: :delete_all), null: false
    end
    create index(:items, [:display_id])
    create index(:items, [:mod_id])

    # link items and displays (n:m)
    create table(:character_items) do
      add :character_id, references(:characters, on_delete: :delete_all), null: false
      add :item_id, references(:items, on_delete: :delete_all), null: false
    end
    create unique_index(:character_items, [:character_id, :item_id])

    # link characters and mods (n:m)
    create table(:character_mods) do
      add :character_id, references(:characters, on_delete: :delete_all), null: false
      add :mod_id, references(:mods, on_delete: :delete_all), null: false
    end

    create unique_index(:character_mods, [:character_id, :mod_id])
  end
end
