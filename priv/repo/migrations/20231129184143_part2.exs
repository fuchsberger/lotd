defmodule Lotd.Repo.Migrations.Part2 do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :admin, :boolean
      remove :avatar_url, :string
      remove :username, :string
      remove :updated_at, :naive_datetime
    end

    drop index(:items, :display_id)

    alter table(:items) do
      remove :display_id, :integer
    end

    drop index(:displays, [:room_id])
    drop table(:displays)

    drop index(:rooms, [:name])
    drop table(:rooms)
  end
end
