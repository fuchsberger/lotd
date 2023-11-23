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

    resources "/display", DisplayController, only: [:index]
    resources "/item", ItemController, only: [:index]
    resources "/location", LocationController, only: [:index]
    resources "/mod", ModController, only: [:index]
    resources "/region", RegionController, only: [:index]
    resources "/room", RoomController, only: [:index]
  end

  scope "/api", LotdWeb.Api, as: :api do
    pipe_through [:api, :require_authenticated_user]

    resources "/character", CharacterController, only: [:create, :update, :delete, :index]
    put "/item/:id/toggle", ItemController, :toggle
    put "/character/:id/activate", CharacterController, :activate
    put "/mod/:id/toggle", ModController, :toggle
    put "/mod/toggle-all", ModController, :toggle_all
  end

  scope "/api", LotdWeb.Api, as: :api do
    pipe_through [:api, :require_authenticated_user, :require_moderator]

    resources "/item", ItemController, only: [:create, :update, :delete]
    resources "/mod", ModController, only: [:create, :update, :delete]
    resources "/region", RegionController, only: [:create, :update, :delete]
    resources "/room", RoomController, only: [:create, :update, :delete]
    resources "/display", DisplayController, only: [:create, :update, :delete]
    resources "/location", LocationController, only: [:create, :update, :delete]
  end

  scope "/api", LotdWeb.Api, as: :api do
    pipe_through [:api, :require_authenticated_user, :require_moderator]

    resources "/user", UserController, only: [:index, :delete]
  end

  scope "/", LotdWeb do
    pipe_through :browser

    get "/", PageController, :item
    get "/about", PageController, :about
    get "/gallery", PageController, :gallery
    get "/mods", PageController, :mod
    get "/displays", PageController, :display
    get "/locations", PageController, :location
    get "/regions", PageController, :region
    get "/rooms", PageController, :room
  end

  scope "/", LotdWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/characters", PageController, :character
  end

  scope "/", LotdWeb do
    pipe_through [:browser, :require_authenticated_user, :require_admin]

    get "/users", PageController, :user
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
