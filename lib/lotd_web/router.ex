defmodule LotdWeb.Router do
  use LotdWeb, :router

  @session [session: [:user_id, csrf_token: Phoenix.Controller.get_csrf_token()]]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug LotdWeb.Auth
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", LotdWeb do
    pipe_through :browser

    live "/", ItemLive, @session
    live "/mods", ModLive, @session

    # get "/", ItemLive, :index
    resources "/session", SessionController, only: [:create, :delete]
    get "/:path", PageController, :not_found
  end
end
