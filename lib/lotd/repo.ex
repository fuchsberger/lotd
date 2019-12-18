defmodule Lotd.Repo do
  use Ecto.Repo,
    otp_app: :lotd,
    adapter: Ecto.Adapters.Postgres

  import Ecto.Query, warn: false
  import Ecto.Changeset, only: [validate_change: 3]

  def ids(module), do: from(i in module, select: i.id)

  def list_options(module) do
    from(x in module, select: {x.id, x.name}, order_by: x.name)
    |> all()
    |> Enum.into(%{}, fn x -> x end)
  end

  def sort_by_id(query), do: from(c in query, order_by: c.id)
  def sort_by_name(query), do: from(c in query, order_by: c.id)
end
