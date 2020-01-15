defmodule LotdWeb.GalleryController do
  use LotdWeb, :controller

  def index(conn, _params) do
    if authenticated?(conn),
      do: redirect(conn, to: Routes.live_path(conn, LotdWeb.GalleryLive)),
      else: redirect(conn, to: Routes.gallery_path(conn, :about))
  end

  def about(conn, _params), do: render(conn, "about.html")

  def not_found(conn, _params) do
    conn
    |> put_flash(:error, "Error 404: The given URL was not found.")
    |> redirect(to: Routes.live_path(conn, LotdWeb.GalleryLive ))
  end
end
