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

  def validate_url(changeset, field, opts \\ []) do
    validate_change changeset, field, fn _, value ->
      case URI.parse(value) do
        %URI{scheme: nil} -> "is missing a scheme (e.g. https)"
        %URI{host: nil} -> "is missing a host"
        %URI{host: host} ->
          case :inet.gethostbyname(Kernel.to_charlist host) do
            {:ok, _} -> nil
            {:error, _} -> "invalid host"
          end
      end
      |> case do
        error when is_binary(error) -> [{field, Keyword.get(opts, :message, error)}]
        _ -> []
      end
    end
  end
end
