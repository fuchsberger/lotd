defmodule LotdWeb.Api.RoomController do
  use LotdWeb, :controller

  alias Lotd.Gallery
  alias Lotd.Gallery.Room
  alias LotdWeb.Api.RoomView

  def index(conn, _params) do
    rooms = Gallery.list_rooms()
    render(conn, "rooms.json", rooms: rooms)
  end

  def create(conn, %{"room" => room_params}) do
    case Gallery.create_room(room_params) do
      {:ok, room} ->
        room = Gallery.preload_room(room)
        json(conn, %{success: true, room: RoomView.render("room.json", room: room )})

      {:error, %Ecto.Changeset{} = _changeset} ->
        json(conn, %{success: false})
    end
  end

  def update(conn, %{"id" => id, "room" => room_params}) do
    with %Room{} = room <- Gallery.get_room!(id) do
      case Gallery.update_room(room, room_params) do
        {:ok, room} ->
          room = Gallery.preload_room(room)
          json(conn, %{success: true, room: RoomView.render("room.json", room: room)})

        {:error, %Ecto.Changeset{} = _changeset} ->
          json(conn, %{success: false})
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    with %Room{} = room <- Gallery.get_room!(id),
        {:ok, room} = Gallery.delete_room(room) do
      json(conn, %{success: true, deleted_id: room.id})
    end
  end
end
