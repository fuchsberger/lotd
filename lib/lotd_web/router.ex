defmodule LotdWeb.Router do
  use LotdWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug LotdWeb.Auth
    plug :put_root_layout, {LotdWeb.LayoutView, :root}
  end

  scope "/", LotdWeb do
    pipe_through :browser

    resources "/", SessionController, only: [:create, :delete]

    live "/", GalleryLive, :index
    live "/about", GalleryLive, :about
    live "/gallery", GalleryLive, :gallery
  end

  scope "/", LotdWeb do
    pipe_through [:browser, :user, :admin]

    live "/users", UserLive
  end
end
