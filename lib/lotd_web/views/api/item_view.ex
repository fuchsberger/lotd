defmodule LotdWeb.Api.ItemView do
  use LotdWeb, :view

  def render("index.json", %{items: items}) do
    %{data: render_many(items, LotdWeb.Api.ItemView, "item.json")}
  end

  def render("item.json", %{ item: item }) do
    [
      item.id,
      item.name,
      item.url
    ]
  end
end
