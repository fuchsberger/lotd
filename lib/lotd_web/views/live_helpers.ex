defmodule LotdWeb.LiveHelpers do
  @moduledoc """
  Conveniences for all live views.
  """

  def sort(results, name, already_sorted? \\ false)

  def sort(results, _sortby, true), do: Enum.reverse(results)

  def sort(results, "name", false), do: Enum.sort_by(results, & &1.name)

  def sort(results, "items", false) do
    results
    |> Enum.sort_by(& Enum.count(&1.items))
    |> Enum.reverse()
  end

  def sort(results, "displays", false), do: Enum.sort_by(results, & &1.display)

  def sort(results, "room", false), do: Enum.sort_by(results, & &1.room)
end
