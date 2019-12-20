defmodule LotdWeb.LiveHelpers do
  @moduledoc """
  Conveniences for all live views.
  """

  def sort(results, "items", "asc"), do: Enum.sort_by(results, fn o -> Enum.count(o.items) end)
  def sort(results, "items", "desc"), do: Enum.reverse(sort(results, "items", "asc"))

  def sort(results, sort, "asc"), do:
    Enum.sort_by(results, fn o -> Map.get(o, String.to_atom(sort)) end)

  def sort(results, sort, "desc") do
    results
    |> Enum.sort_by(fn o -> Map.get(o, String.to_atom(sort)) end)
    |> Enum.reverse()
  end
end
