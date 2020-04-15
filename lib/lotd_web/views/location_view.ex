defmodule LotdWeb.LocationView do
  use LotdWeb, :view

  def locations(regions, filter), do: Enum.find(regions, & &1.id == filter).locations
end
