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

  def sort(results, "filename", already_sorted?) do
    if already_sorted?,
      do: Enum.reverse(results),
      else: Enum.sort_by(results, fn result -> result.filename end)
  end

  def sort(results, "display_count", already_sorted?) do
    if already_sorted?,
      do: Enum.reverse(results),
      else: Enum.sort_by(results, fn result -> Enum.count(result.items) end) |> Enum.reverse()
  end

  def sort(results, "location_count", already_sorted?) do
    if already_sorted?,
      do: Enum.reverse(results),
      else: Enum.sort_by(results, fn result -> Enum.count(result.locations) end) |> Enum.reverse()
  end

  def sort(results, "quest_count", already_sorted?) do
    if already_sorted?,
      do: Enum.reverse(results),
      else: Enum.sort_by(results, fn result -> Enum.count(result.quests) end) |> Enum.reverse()
  end
end
