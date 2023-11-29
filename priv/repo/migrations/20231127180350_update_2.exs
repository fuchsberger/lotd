defmodule Lotd.Repo.Migrations.Update2 do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :active_character_id, :integer
      remove :moderator, :boolean
      remove :hide_aquired_items, :boolean
    end

    drop index(:character_items, [:character_id, :item_id])
    drop table(:character_items)

    drop index(:characters, [:user_id])
    drop table(:characters)
  end
end
