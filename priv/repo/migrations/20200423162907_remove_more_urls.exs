defmodule Lotd.Repo.Migrations.RemoveMoreUrls do
  use Ecto.Migration

  def change do
    alter table(:displays) do
      remove :url
    end

    alter table(:locations) do
      remove :url
    end

    alter table(:mods) do
      remove :url
    end
  end
end
