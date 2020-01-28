defmodule LotdWeb.GalleryController do
  use LotdWeb, :controller

  def index(conn, _params) do
    if is_nil(conn.assigns.current_user),
      do: redirect(conn, to: Routes.gallery_path(conn, :about)),
      else: redirect(conn, to: Routes.live_path(conn, LotdWeb.GalleryLive))
  end

  def about(conn, _params), do: render(conn, "about.html")
end
