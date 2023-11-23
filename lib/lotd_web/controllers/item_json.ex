defmodule LotdWeb.ItemJSON do
 use LotdWeb, :html

  alias Lotd.Gallery.Item

  @doc """
  Renders a list of items.
  """
  def index(%{items: items, character_item_ids: cids}) do
    %{data: for(item <- items, do: data(item, cids))}
  end

  @doc """
  Renders a single item.
  """
  def show(%{item: item, character_item_ids: cids}) do
    %{data: data(item, cids)}
  end

  defp data(%Item{} = item, character_item_ids) do
    [
      item.id in character_item_ids,
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
