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
    plug :put_root_layout, {LotdWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  scope "/api", LotdWeb.Api, as: :api do
    pipe_through :api

    resources "/item", ItemController, only: [:index]
    resources "/mod", ModController, only: [:index]
  end

  scope "/api", LotdWeb.Api, as: :api do
    pipe_through [:api, :require_authenticated_user]

    resources "/character", CharacterController, only: [:create, :update, :delete, :index]
    put "/character/:id/activate", CharacterController, :activate
    put "/mod/:id/toggle", ModController, :toggle
    put "/mod/toggle-all", ModController, :toggle_all
  end

  scope "/api", LotdWeb.Api, as: :api do
    pipe_through [:api, :require_authenticated_user, :require_moderator]

    resources "/mod", ModController, only: [:create, :update, :delete]
    resources "/region", RegionController, only: [:index, :create, :update, :delete]
    resources "/room", RoomController, only: [:index, :create, :update, :delete]
    resources "/display", LocationController, only: [:index, :create, :update, :delete]
    resources "/location", LocationController, only: [:index, :create, :update, :delete]
  end

  scope "/", LotdWeb do
    pipe_through :browser

    get "/", ItemController, :index
    get "/about", PageController, :about
    get "/mods", PageController, :mod
  end

  scope "/", LotdWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/characters", PageController, :character
    resources "/character", CharacterController, except: [:index, :show]

    put "/character/toggle/:item_id", CharacterController, :toggle
  end

  scope "/", LotdWeb do
    pipe_through [:browser, :require_authenticated_user, :require_moderator]

    resources "/item", ItemController, except: [:index, :show]
    get "/item/:id/remove", ItemController, :remove
    resources "/display", DisplayController, except: [:show]
    resources "/location", LocationController, except: [:show]
    resources "/region", RegionController, except: [:show]
    resources "/room", RoomController, except: [:show]
  end

  scope "/", LotdWeb do
    pipe_through [:browser, :require_authenticated_user, :require_admin]
    resources "/users", UserController, only: [:index, :delete]
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
