defmodule LotdWeb.ItemJSON do
 use LotdWeb, :html

  alias Lotd.Gallery.Item

  @doc """
  Renders a list of items.
  """
  def index(%{items: items}) do
    %{data: for(item <- items, do: data(item))}
  end

  @doc """
  Renders a single item.
  """
  def show(%{item: item}) do
    %{data: data(item)}
  end

  defp data(%Item{} = item) do
    [
      item.name,
      item.location && item.location.id,
      item.location && item.location.region_id,
      item.display.id,
      item.display.room_id,
      item.mod_id,
      item.id,
      item.url
    ]
  end
end
