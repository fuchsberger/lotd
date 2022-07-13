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

    # public routes
    # live "/", LotdLive, :index

    live "/gallery", LotdLive, :gallery
    live "/locations", LotdLive, :locations
    # live "/mods", LotdLive, :mods

    # requires authentication
    live "/create_character", LotdLive, :create_character

    # requires authentication and active character
    live "/update_character", LotdLive, :update_character

    # requires authentication and moderator access
    live "/create_item", LotdLive, :create_item
    live "/update_item/:id", LotdLive, :update_item
    live "/create_display", LotdLive, :create_display
    live "/update_display", LotdLive, :update_display
    live "/create_location", LotdLive, :create_location
    live "/update_location", LotdLive, :update_location
    live "/create_mod", LotdLive, :create_mod
    live "/update_mod", LotdLive, :update_mod

    # requires authentication and admin access
    live "/create_room", LotdLive, :create_room
    live "/update_room", LotdLive, :update_room
    live "/create_region", LotdLive, :create_region
    live "/update_region", LotdLive, :update_region
  end

  scope "/", LotdWeb do
    pipe_through [:browser, :require_authenticated_user]

    resources "/character", CharacterController
    get "/character/remove/:id", CharacterController, :remove
    put "/character/activate/:id", CharacterController, :activate
    put "/character/toggle/:item_id", CharacterController, :toggle
    put "/mod/toggle-all", ModController, :toggle_all
    put "/mod/toggle/:id", ModController, :toggle
  end

  scope "/", LotdWeb do
    pipe_through [:browser, :require_authenticated_user, :require_moderator]

    resources "/item", ItemController, except: [:index]
    get "/item/remove/:id", ItemController, :remove
    resources "/display", DisplayController
    resources "/location", LocationController
    resources "/mod", ModController
    get "/mod/remove/:id", ModController, :remove
    resources "/region", RegionController
    resources "/room", RoomController
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
