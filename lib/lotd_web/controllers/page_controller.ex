defmodule LotdWeb.PageController do
  use LotdWeb, :controller

  def index(conn, _params), do: render conn, "index.html"

  def not_found(conn, _params) do
    conn
    |> put_flash(:error, "Error 404: The given URL was not found.")
    |> redirect(to: Routes.live_path(conn, LotdWeb.ItemLive ))
  end
end
