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
    resources "/", PageController, only: [:index]
    resources "/session", SessionController, only: [:create, :delete]
  end
end
