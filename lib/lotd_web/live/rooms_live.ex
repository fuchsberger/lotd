defmodule LotdWeb.RoomsLive do

  use Phoenix.LiveView, container: {:div, class: "container"}

  import LotdWeb.LiveHelpers
  alias Lotd.Gallery
  alias Lotd.Gallery.Room

  def render(assigns), do: LotdWeb.ManageView.render("rooms.html", assigns)

  def mount(_params, _session, socket) do
    {:ok, assign(socket,
      changeset: Gallery.change_room(%Room{}),
      rooms: Gallery.list_rooms()
    )}
  end

  def handle_event("validate", %{"room" => params}, socket) do
    {:noreply, assign(socket, changeset: Room.changeset(socket.assigns.changeset.data, params))}
  end

  def handle_event("save", %{"room" => params}, socket) do
    case Lotd.Repo.insert_or_update(socket.assigns.changeset) do
      {:ok, room } ->
        room = Lotd.Repo.preload(room, :displays)
        {:noreply, assign(socket,
          changeset: Gallery.change_room(%Room{}),
          rooms: update_collection(socket.assigns.rooms, room)
        )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("edit", %{"id" => id}, socket) do
    id = String.to_integer(id)
    if socket.assigns.changeset.data.id == id do
      {:noreply, assign(socket, changeset: Gallery.change_room(%Room{}))}
    else
      room = Enum.find(socket.assigns.rooms, & &1.id == id)
      {:noreply, assign(socket, changeset: Gallery.change_room(room))}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    room = Enum.find(socket.assigns.rooms, & &1.id == socket.assigns.changeset.data.id)
    case Gallery.delete_room(room) do
      {:ok, room} ->
        {:noreply, assign(socket,
          changeset: Gallery.change_room(%Room{}),
          rooms: Enum.reject(socket.assigns.rooms, & &1.id == room.id)
        )}

      {:error, _reason} ->
        {:noreply, socket}
    end

  end
end
