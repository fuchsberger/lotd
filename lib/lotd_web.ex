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
      import Phoenix.LiveView.Controller, only: [live_render: 3]
      import LotdWeb.Gettext

      alias LotdWeb.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "lib/lotd_web/templates", namespace: LotdWeb
      unquote(view_helpers())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView, layout: {LotdWeb.LayoutView, "live.html"}
      unquote(view_helpers())
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

  defp view_helpers do
    quote do
      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML
      use LotdWeb.Components

      # Import LiveView helpers (live_render, live_component, live_patch, etc)
      import Phoenix.LiveView.Helpers

      # Import basic rendering functionality (render, render_layout, etc)
      import Phoenix.View

      import LotdWeb.ErrorHelpers
      import LotdWeb.ViewHelpers
      import LotdWeb.Gettext

      alias LotdWeb.Router.Helpers, as: Routes
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
