defmodule Lotd.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do

    # create mods, rooms and regions first (not foreign key dependencies)
    create table(:mods) do
      add :name, :string, null: false
      add :url, :string
    end

    create unique_index(:mods, [:name])

    create table(:rooms) do
      add :name, :string, null: false
    end

    create unique_index(:rooms, [:name])

    create table(:regions) do
      add :name, :string, null: false
    end

    create unique_index(:regions, [:name])

    # create locations and displays next

    create table(:displays) do
      add :name, :string, null: false
      add :room_id, references(:rooms, on_delete: :nilify_all)
    end
    create index(:displays, [:room_id])


    create table(:locations) do
      add :name, :string, null: false
      add :region_id, references(:regions, on_delete: :nilify_all)
    end

    create index(:locations, [:region_id])
    create unique_index(:locations, [:name])

    # create items next

    create table(:items) do
      add :name, :string, null: false
      add :url, :string
      add :display_id, references(:displays, on_delete: :nilify_all), null: false
      add :location_id, references(:locations, on_delete: :nilify_all)
      add :mod_id, references(:mods, on_delete: :delete_all), null: false
    end
    create index(:items, [:display_id, :mod_id, :location_id])

    # create users
    create table(:users) do
      add :avatar_url, :string
      add :username, :string, null: false
      add :admin, :boolean, null: false
      add :hide_aquired_items, :boolean, default: false, null: false
      add :moderator, :boolean, null: false
      timestamps()
    end

    create table(:users_tokens) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      timestamps(updated_at: false)
    end

    create index(:users_tokens, [:user_id])
    create unique_index(:users_tokens, [:context, :token])

    # create characters
    create table(:characters) do
      add :name, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      timestamps()
    end
    create index(:characters, [:user_id])

    alter table(:users) do
      add :active_character_id, references(:characters, on_delete: :nilify_all)
    end

    # link characters and items (n:m)
    create table(:character_items) do
      add :character_id, references(:characters, on_delete: :delete_all), null: false
      add :item_id, references(:items, on_delete: :delete_all), null: false
    end
    create unique_index(:character_items, [:character_id, :item_id])

    # link users and mods (n:m)
    create table(:user_mods) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :mod_id, references(:mods, on_delete: :delete_all), null: false
    end

    create unique_index(:user_mods, [:user_id, :mod_id])
  end
end
