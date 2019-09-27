defmodule LotdWeb.PageController do
  use LotdWeb, :controller

  # def index(conn, _params), do: redirect(conn, to: "/user")

  def index(conn, _params) do
    render conn, "index.html"
  end
end
