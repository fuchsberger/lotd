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

    live "/", GalleryLive, :home
    live "/armory", GalleryLive, :armory
    live "/hall_of_heroes", GalleryLive, :hall_of_heroes
    live "/dragonborn_hall", GalleryLive, :dragonborn_hall
    live "/safehouse", GalleryLive, :safehouse
    live "/hall_of_secrets", GalleryLive, :hall_of_secrets
    live "/locations", GalleryLive, :locations
    live "/mods", GalleryLive, :mods
    live "/users", UserLive, :users
  end
end
