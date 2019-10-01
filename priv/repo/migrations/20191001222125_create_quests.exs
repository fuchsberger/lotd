defmodule Lotd.Repo.Migrations.CreateQuests do
  use Ecto.Migration

  def change do
    create table(:quests) do
      add :name, :string
      add :url, :string
    end

    create unique_index(:quests, [:name])

    alter table(:items) do
      add :quest_id, references(:quests, on_delete: :nilify_all)
    end

    create index(:items, [:quest_id])
  end
end
