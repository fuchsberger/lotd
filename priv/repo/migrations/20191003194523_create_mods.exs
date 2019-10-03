defmodule Lotd.Repo.Migrations.CreateMods do
  use Ecto.Migration

  def change do
    create table(:mods) do
      add :name, :string
      add :url, :string
      add :filename, :string
    end
    create unique_index(:mods, [:name])
    create unique_index(:mods, [:url])
    create unique_index(:mods, [:filename])

    alter table(:items) do
      add :mod_id, references(:mods, on_delete: :delete_all), null: false
    end
    create index(:items, [:mod_id])

    alter table(:quests) do
      add :mod_id, references(:mods, on_delete: :delete_all), null: false
    end
    create index(:quests, [:mod_id])

    alter table(:locations) do
      add :mod_id, references(:mods, on_delete: :delete_all), null: false
    end
    create index(:locations, [:mod_id])
  end
end
