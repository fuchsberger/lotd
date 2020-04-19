defmodule Lotd.Repo.Migrations.RemoveSomeUrls do
  use Ecto.Migration

  def change do
    alter table(:regions) do
      remove :url
    end

    alter table(:rooms) do
      remove :url
    end
  end
end
