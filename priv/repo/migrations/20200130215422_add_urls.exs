defmodule Lotd.Repo.Migrations.AddUrls do
  use Ecto.Migration

  def change do
    alter table(:displays) do
      modify :room_id, references(:rooms, on_delete: :nilify_all), null: false
    end
  end
end
