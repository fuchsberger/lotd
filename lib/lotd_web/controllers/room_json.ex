defmodule LotdWeb.RoomJSON do
  use LotdWeb, :html

  alias Lotd.Gallery.Room

  @doc """
  Renders a list of rooms.
  """
  def index(%{rooms: rooms}) do
    %{data: for(room <- rooms, do: data(room))}
  end

  @doc """
  Renders a single room.
  """
  def show(%{region: room}) do
    %{data: data(room)}
  end

  defp data(%Room{} = room) do
    [
      room.name,
      Enum.map(room.displays, & &1.id),
      Enum.map(room.displays, & &1.items) |> List.flatten() |> Enum.count(),
      room.id
    ]
  end
end
