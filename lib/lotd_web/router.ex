defmodule LotdWeb.Router do
  use LotdWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug LotdWeb.Auth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LotdWeb do
    pipe_through :browser

    get "/", PageController, :index
    resources "/session", SessionController, only: [:create]
  end

  # Other scopes may use custom stacks.
  # scope "/api", LotdWeb do
  #   pipe_through :api
  # end
end
