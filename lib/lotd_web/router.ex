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

    live "/", LotdLive, :index
    live "/about", LotdLive, :about
    live "/create_character", LotdLive, :create_character
    live "/update_character", LotdLive, :update_character
    live "/gallery", LotdLive, :gallery
    live "/locations", LotdLive, :locations
    live "/mods", LotdLive, :mods
    live "/users", LotdLive, :users
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
