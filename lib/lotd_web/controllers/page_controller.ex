defmodule LotdWeb.PageController do
  use LotdWeb, :controller

  def about(conn, _params) do
    render(conn, "about.html")
  end
end
