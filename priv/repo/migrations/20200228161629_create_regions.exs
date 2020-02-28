defmodule Lotd.Repo.Migrations.CreateRegions do
  use Ecto.Migration

  def change do
    create table(:regions) do
      add :name, :string, null: false
      add :url, :string
    end

    create unique_index(:regions, [:name])

    alter table(:locations) do
      add :region_id, references(:regions, on_delete: :nilify_all)
    end

    create index(:locations, [:region_id])
  end
end
