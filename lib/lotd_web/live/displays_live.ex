defmodule LotdWeb.DisplaysLive do

  use Phoenix.LiveView, container: {:div, class: "container"}

  import LotdWeb.LiveHelpers
  alias Lotd.Gallery
  alias Lotd.Gallery.Display

  def render(assigns), do: LotdWeb.ManageView.render("displays.html", assigns)

  def mount(_params, _session, socket) do
    {:ok, assign(socket,
      changeset: Gallery.change_display(%Display{}),
      displays: Gallery.list_displays(),
      room_options: Gallery.list_room_options()
    )}
  end

  def handle_event("validate", %{"display" => params}, socket) do
    {:noreply, assign(socket,
      changeset: Display.changeset(socket.assigns.changeset.data, params))}
  end

  def handle_event("save", _params, socket) do
    case Lotd.Repo.insert_or_update(socket.assigns.changeset) do
      {:ok, display } ->
        display = Lotd.Repo.preload(display, [:room, :items], force: true)
        {:noreply, assign(socket,
          changeset: Gallery.change_display(%Display{}),
          displays: update_collection(socket.assigns.displays, display)
        )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("edit", %{"id" => id}, socket) do
    id = String.to_integer(id)
    if socket.assigns.changeset.data.id == id do
      {:noreply, assign(socket, changeset: Gallery.change_display(%Display{}))}
    else
      display = Enum.find(socket.assigns.displays, & &1.id == id)
      {:noreply, assign(socket, changeset: Gallery.change_display(display))}
    end
  end

  def handle_event("delete", _params, socket) do
    display = Enum.find(socket.assigns.displays, & &1.id == socket.assigns.changeset.data.id)
    case Gallery.delete_display(display) do
      {:ok, display} ->
        {:noreply, assign(socket,
          changeset: Gallery.change_display(%Display{}),
          displays: Enum.reject(socket.assigns.displays, & &1.id == display.id)
        )}

      {:error, _reason} ->
        {:noreply, socket}
    end

  end
end
