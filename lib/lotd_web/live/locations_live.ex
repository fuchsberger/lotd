defmodule LotdWeb.LocationsLive do

  use Phoenix.LiveView, container: {:div, class: "container"}

  import LotdWeb.LiveHelpers
  alias Lotd.Gallery
  alias Lotd.Gallery.Location

  def render(assigns), do: LotdWeb.ManageView.render("locations.html", assigns)

  def mount(_params, _session, socket) do
    {:ok, assign(socket,
      changeset: Gallery.change_location(%Location{}),
      locations: Gallery.list_locations(),
      region_options: Gallery.list_region_options()
    )}
  end

  def handle_event("validate", %{"location" => params}, socket) do
    {:noreply, assign(socket,
      changeset: Location.changeset(socket.assigns.changeset.data, params))}
  end

  def handle_event("save", _params, socket) do
    case Lotd.Repo.insert_or_update(socket.assigns.changeset) do
      {:ok, location } ->

        changeset =
          %Location{}
          |> Gallery.change_location()
          |> Ecto.Changeset.put_change(:region_id, location.region_id)

        location = Lotd.Repo.preload(location, [:region, :items], force: true)

        {:noreply, assign(socket,
          changeset: changeset,
          locations: update_collection(socket.assigns.locations, location)
        )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("edit", %{"id" => id}, socket) do
    id = String.to_integer(id)

    if socket.assigns.changeset.data.id == id do
      changeset =
        %Location{}
        |> Gallery.change_location()
        |> Ecto.Changeset.put_change(:region_id, socket.assigns.changeset.data.region_id)

      {:noreply, assign(socket, changeset: changeset)}

    else
      location = Enum.find(socket.assigns.locations, & &1.id == id)
      IO.inspect Gallery.change_location(location)
      {:noreply, assign(socket, changeset: Gallery.change_location(location))}
    end
  end

  def handle_event("delete", _params, socket) do
    location = Enum.find(socket.assigns.locations, & &1.id == socket.assigns.changeset.data.id)
    case Gallery.delete_location(location) do
      {:ok, location} ->
        changeset =
          %Location{}
          |> Gallery.change_location()
          |> Ecto.Changeset.put_change(:region_id, location.region_id)

        {:noreply, assign(socket,
          changeset: changeset,
          locations: Enum.reject(socket.assigns.locations, & &1.id == location.id)
        )}

      {:error, _reason} ->
        {:noreply, socket}
    end

  end
end
