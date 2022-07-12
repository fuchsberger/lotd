defmodule LotdWeb.Api.ItemView do
 use LotdWeb, :view

  def render("items.json", %{items: items}) do
    %{
      data: render_many(items, LotdWeb.Api.ItemView, "item.json")
    }
  end

  def render("item.json", %{item: item}) do
    [
      item.id,                              # 0
      Enum.random([true, false]),                                 # 1 collected
      item.name,
      item.location && item.location.name,
      item.location && item.location.region,
      item.display.name,
      item.display.room,
      item.url
    ]
  end
end
