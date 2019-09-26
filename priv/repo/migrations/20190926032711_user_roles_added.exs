defmodule Lotd.Repo.Migrations.UserRolesAdded do
  use Ecto.Migration

  def change do
    alter table(:users) do
      modify :nexus_id, :integer, null: false
      modify :nexus_name, :string, null: false
      add :admin, :boolean, default: false, null: false
      add :moderator, :boolean, default: false, null: false
    end
  end
end
