defmodule LotdWeb.Api.RegionController do
  use LotdWeb, :controller

  alias Lotd.Gallery
  alias Lotd.Gallery.Region
  alias LotdWeb.RegionJSON

  def index(conn, _params) do
    regions = Gallery.list_regions()
    render(conn, "regions.json", regions: regions)
  end

  def create(conn, %{"region" => region_params}) do
    case Gallery.create_region(region_params) do
      {:ok, region} ->
        region = Gallery.preload_region(region)
        json(conn, %{success: true, region: RegionJSON.show(%{region: region})})

      {:error, %Ecto.Changeset{} = _changeset} ->
        json(conn, %{success: false})
    end
  end

  def update(conn, %{"id" => id, "region" => region_params}) do
    with %Region{} = region <- Gallery.get_region!(id) do
      case Gallery.update_region(region, region_params) do
        {:ok, region} ->
          region = Gallery.preload_region(region)
          json(conn, %{success: true, region: RegionJSON.show(%{region: region})})

        {:error, %Ecto.Changeset{} = _changeset} ->
          json(conn, %{success: false})
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    with %Region{} = region <- Gallery.get_region!(id),
        {:ok, region} = Gallery.delete_region(region) do
      json(conn, %{success: true, deleted_id: region.id})
    end
  end
end
