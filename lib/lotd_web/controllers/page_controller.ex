defmodule LotdWeb.PageController do
  use LotdWeb, :controller

  def index(conn, _params) do
    redirect(conn, to: Routes.lotd_path(conn, LotdWeb.LotdLive, :gallery))
  end

  def about(conn, _params), do: render(conn, "about.html")
end
