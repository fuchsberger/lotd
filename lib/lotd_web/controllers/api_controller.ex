defmodule LotdWeb.Api.ItemController do
  use LotdWeb, :controller

  def index(conn, _params) do
    items = Lotd.Gallery.list_items(:complete)
    # json(conn, %{data: items})

    render(conn, "items.json", items: items)
  end
end
