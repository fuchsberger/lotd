defmodule LotdWeb.DisplayJSON do
  use LotdWeb, :html

  alias Lotd.Gallery.Display

  @doc """
  Renders a list of displays.
  """
  def index(%{displays: displays}) do
    %{data: for(display <- displays, do: data(display))}
  end

  @doc """
  Renders a single display.
  """
  def show(%{display: display}) do
    %{data: data(display)}
  end

  defp data(%Display{} = display) do
    [
      display.items,
      display.name,
      display.room_id,
      display.id
    ]
  end
end
