defmodule Lotd.Repo.Migrations.CreateLocations do
  use Ecto.Migration

  def change do
    create unique_index(:items, [:name])
    create unique_index(:displays, [:name])

    create table(:locations) do
      add :name, :string
      add :url, :string
    end

    create unique_index(:locations, [:name])

    alter table(:items) do
      add :location_id, references(:locations, on_delete: :nilify_all)
    end

    create index(:items, [:location_id])
  end
end
