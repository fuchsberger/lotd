defmodule LotdWeb.Router do
  use LotdWeb, :router

  @session [session: [ "user_id" ]]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug LotdWeb.Auth
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", LotdWeb do
    pipe_through :browser

    get "/", GalleryController, :index
    get "/about", GalleryController, :about

    live "/gallery", GalleryLive, @session

    resources "/session", SessionController, only: [:create, :delete]
  end

  scope "/", LotdWeb do
    pipe_through [:browser, :authenticate_user]

    live "/settings", SettingsLive, @session
  end
end
