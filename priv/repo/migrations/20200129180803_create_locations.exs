defmodule Lotd.Repo.Migrations.CreateLocations do
  use Ecto.Migration

  def change do

    alter table(:mods) do
      modify :name, :string, null: false
    end

    create table(:locations) do
      add :name, :string, null: false
    end
    create unique_index(:locations, [:name])

    alter table(:items) do
      add :location_id, references(:locations, on_delete: :nilify_all)
    end

    create index(:items, [:location_id])
  end
end
