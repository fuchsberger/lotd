defmodule Lotd.Repo.Migrations.AddReplicas do
  use Ecto.Migration

  def change do
    alter table(:items) do
      add :replica, :boolean, default: false, null: false
    end
  end
end
