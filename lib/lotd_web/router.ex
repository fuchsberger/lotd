defmodule LotdWeb.Router do
  use LotdWeb, :router

  @session [session: [ :user_id ]]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug LotdWeb.Auth
    plug :fetch_flash
    # plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", LotdWeb do
    pipe_through :browser

    get "/", GalleryController, :index
    get "/about", GalleryController, :about

    # Gallery Pages
    live "/gallery", GalleryLive, @session

    live "/characters", CharacterLive, @session
    live "/displays", DisplayLive, @session

    live "/mods", ModLive, @session

    resources "/session", SessionController, only: [:create, :delete]
    get "/:path", GalleryController, :not_found
  end
end
