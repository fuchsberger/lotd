defmodule LotdWeb.Api.ItemView do
  use LotdWeb, :view

  def render("index.json", %{items: items}) do
    %{ data: render_many(items, LotdWeb.Api.ItemView, "item.json") }
  end

  def render("item.json", %{ item: i }) do
    item = [
      i.id,
      i.name,
      i.url
    ]

    # load collected status for authenticated users
    if Ecto.assoc_loaded?(i.characters) do
      [ Enum.count(i.characters) == 1 | item ]
    else
      item
    end
  end
end
