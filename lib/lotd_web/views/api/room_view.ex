defmodule LotdWeb.Api.RoomView do
  use LotdWeb, :view

  def render("rooms.json", %{rooms: rooms}) do
    %{
      data: render_many(rooms, LotdWeb.Api.RoomView, "room.json")
    }
  end

  def render("room.json", %{room: room}) do
    [
      room.name,
      Enum.map(room.displays, & &1.id),
      Enum.map(room.displays, & &1.items) |> List.flatten() |> Enum.count(),
      room.id
    ]
  end
end
