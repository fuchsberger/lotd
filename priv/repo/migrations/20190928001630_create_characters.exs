defmodule Lotd.Repo.Migrations.CreateCharacters do
  use Ecto.Migration

  def change do
    create table(:characters) do
      add :name, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      timestamps()
    end
    create index(:characters, [:user_id])
  end
end
