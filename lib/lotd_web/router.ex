defmodule LotdWeb.Router do
  use LotdWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug LotdWeb.Auth
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LotdWeb do
    pipe_through :browser

    live "/items", ItemLive.Index, session: [:user_id]

    get "/", PageController, :index
    resources "/session", SessionController, only: [:create, :delete]
    get "/:path", PageController, :not_found
  end
end
