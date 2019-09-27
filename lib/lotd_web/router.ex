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

  # Public Routes
  scope "/", LotdWeb do
    pipe_through :browser

    get "/", PageController, :index
    resources "/session", SessionController, only: [:create, :delete]
  end

  # Authenticated Routes
  scope "/", LotdWeb do
    pipe_through [:browser, :is_authenticated]

  end

  # Moderator Routes
  scope "/", LotdWeb do
    pipe_through [:browser, :is_moderator]

  end

  # Admin Routes
  scope "/", LotdWeb do
    pipe_through [:browser, :is_admin]
    resources "/user", UserController, only: [:index, :update]
  end
end
