defmodule LotdWeb.Router do
  use LotdWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug LotdWeb.Auth
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug LotdWeb.Auth
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/api", LotdWeb.Api, as: :api do
    pipe_through :api

    resources "/items", ItemController, only: [:show, :index]
  end

  scope "/api", LotdWeb.Api, as: :api do
    pipe_through [:api, :authenticate_user]

    post "/items/toggle/:id", ItemController, :toggle
  end

  scope "/", LotdWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/about", PageController, :about

    live "/gallery", GalleryLive
    get "/items", ItemController, :index

    resources "/session", SessionController, only: [:create, :delete]
  end

  scope "/", LotdWeb do
    pipe_through [:browser, :authenticate_user]

    live "/settings", SettingsLive
  end

  scope "/", LotdWeb do
    pipe_through [:browser, :authenticate_user, :authenticate_moderator_or_admin]

    live "/users", UserLive
  end
end
