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

    resources "/", ItemController, only: [:index]
    resources "/session", SessionController, only: [:create, :delete]
    resources "/displays", DisplayController, only: [:index]
    resources "/locations", LocationController, only: [:index]
    resources "/quests", QuestController, only: [:index]
    resources "/mods", ModController, only: [:index]
  end

  # Authenticated Routes
  scope "/", LotdWeb do
    pipe_through [:browser, :is_authenticated]
    resources "/characters", CharacterController, except: [:show]
    put "/characters/:id/activate", CharacterController, :activate
    put "/mods/:id/activate", ModController, :activate
    put "/mods/:id/deactivate", ModController, :deactivate
  end

  # Moderator Routes
  scope "/", LotdWeb do
    pipe_through [:browser, :is_moderator]
    resources "/items", ItemController, except: [:index, :delete]
    resources "/displays", DisplayController, except: [:index]
    resources "/locations", LocationController, except: [:index]
    resources "/quests", QuestController, except: [:index]
  end

  # Admin Routes
  scope "/", LotdWeb do
    pipe_through [:browser, :is_admin]
    resources "/mods", ModController, except: [:index]
    resources "/users", UserController, only: [:index, :update]
  end
end
