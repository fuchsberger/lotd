defmodule Lotd.Repo.Migrations.UpdateAuthenticationSystem do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    rename table(:users), :hide, to: :hide_aquired_items
    rename table(:users), :name, to: :username

    alter table(:users) do
      add :avatar_url, :string
    end
  end
end
