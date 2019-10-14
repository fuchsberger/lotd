defmodule LotdWeb.PageController do
  use LotdWeb, :controller

  def index(conn, _params), do: render conn, "index.html"

  def not_found(conn, _params) do
    conn
    |> put_flash(:error, "The given URL was not found.")
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
