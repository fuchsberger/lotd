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

    get "/items", ItemController, :index
  end

  scope "/", LotdWeb do
    pipe_through :browser

    get "/", ItemController, :index
    get "/about", PageController, :about
    get "/mods", ModController, :index
  end

  scope "/", LotdWeb do
    pipe_through [:browser, :require_authenticated_user]

    resources "/character", CharacterController, except: [:show]
    get "/character/remove/:id", CharacterController, :remove
    put "/character/activate/:id", CharacterController, :activate
    put "/character/toggle/:item_id", CharacterController, :toggle
    put "/mod/toggle-all", ModController, :toggle_all
    put "/mod/toggle/:id", ModController, :toggle
  end

  scope "/", LotdWeb do
    pipe_through [:browser, :require_authenticated_user, :require_moderator]

    resources "/item", ItemController, except: [:index, :show]
    get "/item/remove/:id", ItemController, :remove
    resources "/display", DisplayController, except: [:show]
    resources "/location", LocationController, except: [:show]
    resources "/mod", ModController, except: [:index, :show]
    get "/mod/remove/:id", ModController, :remove
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
