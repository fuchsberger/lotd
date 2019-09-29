defmodule Lotd.Repo.Migrations.CreateDisplays do
  use Ecto.Migration

  def change do
    create table(:displays) do
      add :name, :string, null: false
      add :url, :string
    end

    alter table(:items) do
      add :display_id, references(:displays, on_delete: :delete_all), null: false
    end
    create index(:items, [:display_id])
  end
end
