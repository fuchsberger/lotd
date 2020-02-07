defmodule LotdWeb.Api.ItemController do
  use LotdWeb, :controller

  alias Lotd.Gallery

  def index(conn, _params) do
    items = Gallery.list_items()
    render(conn, "index.json", items: items)
  end

  def show(conn, %{"id" => id}) do
    item = Gallery.get_item!(id)
    render(conn, "show.json", item: item)
  end
end
