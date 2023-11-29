defmodule LotdWeb.Router do
  use LotdWeb, :router

  import LotdWeb.UserAuth

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug :fetch_current_user
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {LotdWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  scope "/api", LotdWeb.Api, as: :api do
    pipe_through :api

    resources "/item", ItemController, only: [:index]
    resources "/location", LocationController, only: [:index]
    resources "/mod", ModController, only: [:index]
    resources "/region", RegionController, only: [:index]
  end

  scope "/api", LotdWeb.Api, as: :api do
    pipe_through [:api, :require_authenticated_user]

    put "/mod/:id/toggle", ModController, :toggle
    put "/mod/toggle-all", ModController, :toggle_all
  end

  scope "/api", LotdWeb.Api, as: :api do
    pipe_through [:api, :require_authenticated_user, :require_admin]

    resources "/item", ItemController, only: [:create, :update, :delete]
    resources "/mod", ModController, only: [:create, :update, :delete]
    resources "/region", RegionController, only: [:create, :update, :delete]
    resources "/location", LocationController, only: [:create, :update, :delete]
  end

  scope "/", LotdWeb do
    pipe_through :browser

    live "/", LotdLive, :index
    live "/login", LotdLive, :login

    get "/about", PageController, :about
    get "/gallery", PageController, :gallery
    get "/mods", PageController, :mod
    get "/locations", PageController, :location
    get "/regions", PageController, :region
  end

  scope "/", LotdWeb do
    pipe_through [:browser, :require_authenticated_user, :require_admin]

    get "/users", PageController, :user
    resources "/user", UserController, only: [:index, :delete]
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
