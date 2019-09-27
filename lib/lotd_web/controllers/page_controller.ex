defmodule LotdWeb.PageController do
  use LotdWeb, :controller

  def index(conn, _params), do: redirect(conn, to: "/user")
end
