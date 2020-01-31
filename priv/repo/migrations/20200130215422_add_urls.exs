defmodule Lotd.Repo.Migrations.AddUrls do
  use Ecto.Migration

  def change do
    alter table(:displays) do
      add :url, :string
    end

    alter table(:locations) do
      add :url, :string
    end

    alter table(:mods) do
      add :url, :string
    end

    alter table(:rooms) do
      add :url, :string
    end
  end
end
