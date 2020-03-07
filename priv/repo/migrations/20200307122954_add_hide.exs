defmodule Lotd.Repo.Migrations.AddHide do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :hide, :boolean, default: false, null: false
    end
  end
end
