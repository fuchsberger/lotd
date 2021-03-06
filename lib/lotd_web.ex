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
      use Phoenix.HTML

      import Phoenix.HTML.Form,
        except: [select: 3, select: 4, text_input: 2, text_input: 3, url_input: 3]

      import LotdWeb.Icons
      import LotdWeb.ViewHelpers
      import Phoenix.LiveView.Helpers
      import LotdWeb.ErrorHelpers
      import LotdWeb.Gettext


      alias LotdWeb.Router.Helpers, as: Routes
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

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
