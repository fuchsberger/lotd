defmodule LotdWeb.RegionJSON do
  use LotdWeb, :html

  alias Lotd.Gallery.Region

  @doc """
  Renders a list of regions.
  """
  def index(%{regions: regions}) do
    %{data: for(region <- regions, do: data(region))}
  end

  @doc """
  Renders a single region.
  """
  def show(%{region: region}) do
    %{data: data(region)}
  end

  defp data(%Region{} = region) do
    [
      region.name,
      Enum.map(region.locations, & &1.id),
      Enum.map(region.locations, & &1.items) |> List.flatten() |> Enum.count(),
      region.id
    ]
  end
end
