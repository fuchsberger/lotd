defmodule LotdWeb.LocationController do
  use LotdWeb, :controller

  alias Lotd.Skyrim
  alias Lotd.Skyrim.Location

  def index(conn, _params) do
    character_item_ids = character_item_ids(conn)
    locations = Skyrim.list_alphabetical_locations()
    |> Enum.map(fn l ->
      location_item_ids = Enum.map(l.items, fn i -> i.id end)
      common_ids = location_item_ids -- character_item_ids
      common_ids = location_item_ids -- common_ids
      Map.put(l, :character_item_count, Enum.count(common_ids))
    end)
    render(conn, "index.html", locations: locations)
  end

  def new(conn, _params) do
    changeset = Skyrim.change_location(%Location{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"location" => location_params}) do
    case Skyrim.create_location(location_params) do
      {:ok, _location} ->
        redirect(conn, to: Routes.location_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    location = Skyrim.get_location!(id)
    changeset = Skyrim.change_location(location)
    render(conn, "edit.html", changeset: changeset)
  end

  def update(conn, %{"id" => id, "location" => location_params}) do
    location = Skyrim.get_location!(id)
    case Skyrim.update_location(location, location_params) do
      {:ok, _location} ->
        redirect(conn, to: Routes.location_path(conn, :index))
      {:error, changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    location = Skyrim.get_location!(id)
    {:ok, _location} = Skyrim.delete_location(location)

    conn
    |> put_flash(:info, "Location deleted successfully.")
    |> redirect(to: Routes.location_path(conn, :index))
  end
end
