defmodule Lotd.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :nexus_id, :integer
      add :nexus_name, :string

      timestamps()
    end

    create unique_index(:users, [:nexus_id])
  end
end
