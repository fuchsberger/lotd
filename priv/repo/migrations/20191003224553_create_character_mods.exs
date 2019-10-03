defmodule Lotd.Repo.Migrations.CreateCharacterMods do
  use Ecto.Migration

  def change do
    # link characters and mods
    create table(:characters_mods) do
      add :character_id, references(:characters, on_delete: :delete_all), null: false
      add :mod_id, references(:mods, on_delete: :delete_all), null: false
    end

    create unique_index(:characters_mods, [:character_id, :mod_id])
  end
end
