defmodule LotdWeb.Api.ItemController do
  use LotdWeb, :controller

  def index(conn, _params) do
    items = Lotd.Gallery.list_items(:complete)

    render(conn, "items.json", items: items)
  end
end
