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

  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)

  def router do
    quote do
      use Phoenix.Router, helpers: false

      # Import common connection and controller functions to use in pipelines
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  def controller do
    quote do
      use Phoenix.Controller,
        formats: [:html, :json],
        layouts: [html: LotdWeb.Layouts]

      import Plug.Conn
      import LotdWeb.Gettext
      import Phoenix.LiveView.Controller, only: [live_render: 3]

      unquote(verified_routes())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        container: {:div, class: "flex flex-col h-full"},
        layout: {LotdWeb.Layouts, "live.html"}

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

  def html do
    quote do
      use Phoenix.Component, global_prefixes: ~w(x-)

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      # HTML escaping functionality
      import Phoenix.HTML
      # Core UI components and translation
      import LotdWeb.Components
      import LotdWeb.Gettext

      import Phoenix.Component
      import LotdWeb.ErrorHelpers
      import LotdWeb.ViewHelpers
      import LotdWeb.Gettext

      # Shortcut for generating JS commands
      alias Phoenix.LiveView.JS

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
