defmodule LotdWeb.LayoutView do
  use LotdWeb, :view

  import Phoenix.Controller, only: [current_path: 2]

  def nav_item(conn, name, to, icon) do
    active = if current_path(conn, %{}) == to, do: " active", else: ""
    link [icon(icon), name], to: to, class: "navbar-item#{active}"
  end
end
