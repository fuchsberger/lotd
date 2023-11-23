defmodule LotdWeb.LocationJSON do
  use LotdWeb, :html

  alias Lotd.Gallery.Location

  @doc """
  Renders a list of locations.
  """
  def index(%{locations: locations}) do
    %{data: for(location <- locations, do: data(location))}
  end

  @doc """
  Renders a single location.
  """
  def show(%{location: location}) do
    %{data: data(location)}
  end

  defp data(%Location{} = location) do
    [
      location.items,
      location.name,
      location.region_id,
      location.id
    ]
  end
end
