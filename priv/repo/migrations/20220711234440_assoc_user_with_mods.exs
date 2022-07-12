defmodule Lotd.Repo.Migrations.AssocUserWithMods do
  use Ecto.Migration

  def change do
    # link uers and mods (n:m)
    create table(:user_mods) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :mod_id, references(:mods, on_delete: :delete_all), null: false
    end

    create unique_index(:user_mods, [:user_id, :mod_id])

    drop index(:character_mods, [:character_id, :mod_id])
    drop table(:character_mods)

    alter table(:items) do
      remove :replica
    end
  end
end
