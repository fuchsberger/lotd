defmodule LotdWeb.Components.Icon do
  use LotdWeb, :ui_component

  @doc """
  Dynamically use any Heroicon via the name attribute.

    __Usage:__
    ```heex
    <.icon name={:bars_3} mini class="" />
    ```
  """
  attr :mini, :boolean, default: true
  attr :name, :atom, required: true
  attr :rest, :global, doc: "the arbitrary HTML attributes for the svg container"

  def icon(assigns), do: apply(Heroicons, assigns.name, [assigns])
end
