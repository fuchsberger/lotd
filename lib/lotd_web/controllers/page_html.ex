defmodule LotdWeb.PageHTML do
  use LotdWeb, :html

  defp map(options) do
    options
    |> Enum.map(&{elem(&1, 1), elem(&1, 0)})
    |> Enum.into(%{})
    |> Jason.encode!()
  end
end
