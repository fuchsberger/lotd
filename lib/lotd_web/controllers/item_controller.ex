defmodule LotdWeb.ItemController do
  use LotdWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
