defmodule LotdWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use LotdWeb, :controller
      use LotdWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: LotdWeb

      import Plug.Conn
      import Phoenix.LiveView.Controller
      import LotdWeb.Gettext

      import LotdWeb.ViewHelpers, only: [
        authenticated?: 1,
        active_character_id: 1,
        admin?: 1,
        character: 1,
        character_item_ids: 1,
        character_mod_ids: 1,
        moderator?: 1,
        user: 1,
      ]
      alias LotdWeb.Router.Helpers, as: Routes

      require Logger
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView, root: "lib/lotd_web/templates", namespace: LotdWeb
      use Phoenix.HTML

      import LotdWeb.ViewHelpers, only: [authenticated?: 1]
      # import LotdWeb.ErrorHelpers
      # import LotdWeb.Gettext
      # alias LotdWeb.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "lib/lotd_web/templates", namespace: LotdWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [controller_module: 1, get_flash: 1, get_flash: 2, view_module: 1]

      import Phoenix.LiveView, only: [
        live_render: 2, live_render: 3, live_link: 1, live_link: 2,
        live_component: 2, live_component: 3, live_component: 4
      ]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import LotdWeb.ViewHelpers
      import LotdWeb.ErrorHelpers
      import LotdWeb.Gettext
      alias LotdWeb.Router.Helpers, as: Routes
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
      import LotdWeb.Auth, only: [is_authenticated: 2, is_moderator: 2, is_admin: 2]
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import LotdWeb.Gettext
      import LotdWeb.ErrorHelpers, only: [error_map: 1]
      import LotdWeb.UserSocket, only: [character: 1, authenticated?: 1, moderator?: 1, admin?: 1]

      alias LotdWeb.DataView
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
