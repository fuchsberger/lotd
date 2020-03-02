defmodule LotdWeb.Router do
  use LotdWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug LotdWeb.Auth
  end

  scope "/", LotdWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/about", PageController, :about

    live "/gallery", GalleryLive

    resources "/session", SessionController, only: [:create, :delete]
  end

  scope "/", LotdWeb do
    pipe_through [:browser, :user]

    live "/characters", CharactersLive
  end

  scope "/", LotdWeb do
    pipe_through [:browser, :user, :moderator]

    live "/items", ItemsLive
    live "/rooms", RoomsLive
    live "/displays", DisplaysLive
    live "/regions", RegionsLive
    live "/locations", LocationsLive
    live "/mods", ModsLive
  end

  scope "/", LotdWeb do
    pipe_through [:browser, :user, :admin]

    live "/users", UserLive
  end
end
