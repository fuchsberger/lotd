defmodule LotdWeb.LiveHelpers do
  @moduledoc """
  Conveniences for all live views.
  """

  use Phoenix.HTML

  alias Lotd.Museum\

  def sort(results, name, already_sorted? \\ false)

  def sort(results, "name", already_sorted?) do
    if already_sorted?,
      do: Enum.reverse(results),
      else: Enum.sort_by(results, fn o -> o.name end)
  end

  def sort(results, "items", already_sorted?) do
    if already_sorted?,
      do: Enum.reverse(results),
      else: Enum.sort_by(results, fn o -> Enum.count(o.items) end) |> Enum.reverse()
  end

  def sort(results, "displays", already_sorted?) do
    if already_sorted?,
      do: Enum.reverse(results),
      else: Enum.sort_by(results, fn o -> o.display.name end)
  end

  def sort(results, "room", already_sorted?) do
    if already_sorted?,
      do: Enum.reverse(results),
      else: Enum.sort_by(results, fn o -> Museum.get_room(o.display.room) end)
  end
end
