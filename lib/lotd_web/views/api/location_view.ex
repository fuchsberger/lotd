defmodule LotdWeb.Api.LocationView do
  use LotdWeb, :view

  def render("locations.json", %{locations: locations}) do
    %{
      data: render_many(locations, LotdWeb.Api.LocationView, "location.json")
    }
  end

  def render("location.json", %{location: location}) do
    [
      location.items,
      location.name,
      location.region_id,
      location.id
    ]
  end
end
