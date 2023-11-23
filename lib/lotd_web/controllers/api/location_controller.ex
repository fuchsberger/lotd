defmodule LotdWeb.Api.LocationController do
  use LotdWeb, :controller

  alias Lotd.Gallery
  alias Lotd.Gallery.Location
  alias LotdWeb.LocationJSON

  def index(conn, _params) do
    render(conn, "locations.json", locations: Gallery.list_locations())
  end

  def create(conn, %{"location" => location_params}) do
    case Gallery.create_location(location_params) do
      {:ok, location} ->
        location = Gallery.preload_location(location)
        json(conn, %{
          success: true,
          location: LocationJSON.show(%{location: location})
        })

      {:error, %Ecto.Changeset{} = _changeset} ->
        json(conn, %{success: false})
    end
  end

  def update(conn, %{"id" => id, "location" => location_params}) do
    with %Location{} = location <- Gallery.get_location!(id) do
      case Gallery.update_location(location, location_params) do
        {:ok, location} ->
          location = Gallery.preload_location(location)
          json(conn, %{success: true, location: LocationJSON.show(%{location: location})})

        {:error, %Ecto.Changeset{} = _changeset} ->
          json(conn, %{success: false})
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    with %Location{} = location <- Gallery.get_location!(id),
        {:ok, location} = Gallery.delete_location(location) do
      json(conn, %{success: true, deleted_id: location.id})
    end
  end
end
