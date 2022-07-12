defmodule Lotd.Repo.Migrations.AddModUrl do
  use Ecto.Migration

  def change do
    alter table(:mods) do
      add :url, :string
      remove :initials
    end
  end
end
