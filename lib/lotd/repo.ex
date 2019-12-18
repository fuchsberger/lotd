defmodule Lotd.Repo do
  use Ecto.Repo, otp_app: :lotd, adapter: Ecto.Adapters.Postgres

  import Ecto.Query, warn: false

  def ids(module), do: from(i in module, select: i.id)

  def sort_by_id(query), do: from(c in query, order_by: c.id)
  def sort_by_name(query), do: from(c in query, order_by: c.id)
end
