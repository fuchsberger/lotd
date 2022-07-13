defmodule LotdWeb.Api.ItemView do
 use LotdWeb, :view

  def render("items.json", %{items: items, character_item_ids: cids}) do
    %{
      data: render_many(items, LotdWeb.Api.ItemView, "item.json", character_item_ids: cids)
    }
  end

  def render("item.json", %{item: item, character_item_ids: character_item_ids}) do
    [
      item.id in character_item_ids,
      item.name,
      item.location && item.location.name,
      item.location && item.location.region,
      item.display.name,
      item.display.room,
      item.url,
      item.id
    ]
  end
end
