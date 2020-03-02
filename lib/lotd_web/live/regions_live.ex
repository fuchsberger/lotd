defmodule LotdWeb.RegionsLive do

  use Phoenix.LiveView, container: {:div, class: "container"}

  import LotdWeb.LiveHelpers
  alias Lotd.Gallery
  alias Lotd.Gallery.Region

  def render(assigns), do: LotdWeb.ManageView.render("regions.html", assigns)

  def mount(_params, _session, socket) do
    {:ok, assign(socket,
      changeset: Gallery.change_region(%Region{}),
      regions: Gallery.list_regions()
    )}
  end

  def handle_event("validate", %{"region" => params}, socket) do
    {:noreply, assign(socket, changeset: Region.changeset(socket.assigns.changeset.data, params))}
  end

  def handle_event("save", _params, socket) do
    case Lotd.Repo.insert_or_update(socket.assigns.changeset) do
      {:ok, region } ->
        region = Lotd.Repo.preload(region, :locations)
        {:noreply, assign(socket,
          changeset: Gallery.change_region(%Region{}),
          regions: update_collection(socket.assigns.regions, region)
        )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("edit", %{"id" => id}, socket) do
    id = String.to_integer(id)
    if socket.assigns.changeset.data.id == id do
      {:noreply, assign(socket, changeset: Gallery.change_region(%Region{}))}
    else
      region = Enum.find(socket.assigns.regions, & &1.id == id)
      {:noreply, assign(socket, changeset: Gallery.change_region(region))}
    end
  end

  def handle_event("delete", _params, socket) do
    region = Enum.find(socket.assigns.regions, & &1.id == socket.assigns.changeset.data.id)
    case Gallery.delete_region(region) do
      {:ok, region} ->
        {:noreply, assign(socket,
          changeset: Gallery.change_region(%Region{}),
          regions: Enum.reject(socket.assigns.regions, & &1.id == region.id)
        )}

      {:error, _reason} ->
        {:noreply, socket}
    end

  end
end
