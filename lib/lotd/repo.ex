defmodule Lotd.Repo do
  use Ecto.Repo,
    otp_app: :lotd,
    adapter: Ecto.Adapters.Postgres
end
