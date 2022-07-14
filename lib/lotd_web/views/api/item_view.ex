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
