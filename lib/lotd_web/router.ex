defmodule LotdWeb.Router do

  use LotdWeb, :router
  import Phoenix.LiveView.Router

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
    live "/locations", GalleryLive, :locations
    live "/mods", GalleryLive, :mods
    live "/users", UserLive, :users
  end
end
