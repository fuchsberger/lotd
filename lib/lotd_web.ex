defmodule LotdWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, components, channels, and so on.

  This can be used in your application as:

      use LotdWeb, :controller
      use LotdWeb, :html

  The definitions below will be executed for every controller,
  component, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define additional modules and import
  those modules here.
  """

  def static_paths, do: ~w(assets fonts images uploads favicon.ico robots.txt)

  def controller do
    quote do
      use Phoenix.Controller, namespace: LotdWeb

      import Plug.Conn
      import Phoenix.LiveView.Controller, only: [live_render: 3]
      import LotdWeb.Gettext

      alias LotdWeb.Router.Helpers, as: Routes
    end
  end

  def html do
    quote do
      use Phoenix.Component, global_prefixes: ~w(x-)

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent
      import LotdWeb.LotdLive, only: [broadcast: 2]

      unquote(html_helpers())
    end
  end

  def ui_component do
    quote do
      use Phoenix.Component, global_prefixes: ~w(x-)

      import LotdWeb.Gettext
      import LotdWeb.Components.UI.Helpers
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView, layout: {LotdWeb.Layouts, "live.html"}
      unquote(html_helpers())
    end
  end

  def router do
    quote do
      use Phoenix.Router

      import Phoenix.LiveView.Router
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  defp html_helpers do
    quote do
      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML
      use LotdWeb.Components

      import Phoenix.Component

      import LotdWeb.ErrorHelpers
      import LotdWeb.ViewHelpers
      import LotdWeb.Gettext

      unquote(verified_routes())
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: LotdWeb.Endpoint,
        router: LotdWeb.Router,
        statics: LotdWeb.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
