defmodule Lotd.Repo.Migrations.RemoveActiveCharacterConstraint do
  use Ecto.Migration

  def change do
    alter table(:users) do
      modify :active_character_id, :integer
    end
  end
end
