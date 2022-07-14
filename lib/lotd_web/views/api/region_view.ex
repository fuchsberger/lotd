defmodule LotdWeb.Api.RegionView do
  use LotdWeb, :view

  def render("regions.json", %{regions: regions}) do
    %{
      data: render_many(regions, LotdWeb.Api.RegionView, "region.json")
    }
  end

  def render("region.json", %{region: region}) do
    [
      region.name,
      Enum.map(region.locations, & &1.id),
      Enum.map(region.locations, & &1.items) |> List.flatten() |> Enum.count(),
      region.id
    ]
  end
end
