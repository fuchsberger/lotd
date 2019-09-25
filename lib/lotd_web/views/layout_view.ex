defmodule LotdWeb.LayoutView do
  use LotdWeb, :view

  def authenticated?(conn), do: conn.assigns.current_user

  def unique_view_name(view_module, view_template) do
    [action, "html"] = String.split(view_template, ".")

    view_module
    |> Phoenix.Naming.resource_name()
    |> String.replace("_view", "/#{action}")
  end
end
