defmodule Lotd.Repo.Migrations.ModInitials do
  use Ecto.Migration

  def change do
    alter table(:mods) do
      add :initials, :string
    end
  end
end
