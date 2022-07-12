defmodule LotdWeb.ModController do
  use LotdWeb, :controller

  def index(conn, _params) do
    mods = Lotd.Gallery.list_mods()
    render(conn, "index.html", mods: mods)
  end
end
