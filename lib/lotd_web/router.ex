defmodule LotdWeb.Router do
  use LotdWeb, :router

  import LotdWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {LotdWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  scope "/", LotdWeb do
    pipe_through :browser

    # public routes
    live "/", LotdLive, :index
    live "/about", LotdLive, :about
    live "/gallery", LotdLive, :gallery
    live "/locations", LotdLive, :locations
    live "/mods", LotdLive, :mods

    # requires authentication
    live "/create_character", LotdLive, :create_character

    # requires authentication and active character
    live "/update_character", LotdLive, :update_character

    # requires authentication and moderator access
    live "/create_location", LotdLive, :create_location
    live "/update_location", LotdLive, :update_location
    live "/create_room", LotdLive, :create_room
    live "/update_room", LotdLive, :update_room
    live "/create_region", LotdLive, :create_region
    live "/update_region", LotdLive, :update_region

    # requires authentication and admin access
    live "/users", LotdLive, :users

    # handle 404 in live view
    live "/*unknown", LotdLive, :unknown_url
  end

  ## Authentication routes
  scope "/", LotdWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]
    post "/login", UserSessionController, :create
  end

  scope "/", LotdWeb do
    pipe_through [:browser]
    delete "/logout", UserSessionController, :delete
  end
end
