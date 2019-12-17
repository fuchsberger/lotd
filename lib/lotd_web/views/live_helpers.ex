defmodule LotdWeb.LiveHelpers do
  @moduledoc """
  Conveniences for all live views.
  """

  use Phoenix.HTML


  def sort(results, name, already_sorted? \\ false)

  def sort(results, "name", already_sorted?) do
    if already_sorted?,
      do: Enum.reverse(results),
      else: Enum.sort_by(results, fn mod -> mod.name end)
  end

  def sort(results, "items", already_sorted?) do
    if already_sorted?,
      do: Enum.reverse(results),
      else: Enum.sort_by(results, fn result -> Enum.count(result.items) end) |> Enum.reverse()
  end
end
