defmodule LotdWeb.LayoutView do
  use LotdWeb, :view

  import Phoenix.Controller, only: [current_path: 2]

  def logout_button(conn) do
    link [icon("logout"), conn.assigns.current_user.name ],
      to: Routes.session_path(conn, :delete, conn.assigns.current_user.id),
      method: "delete",
      id: "logout-button",
      class: "nav-link font-weight-bold",
      data_toggle: "tooltip",
      title: "Logout"
  end

  def nav_item(conn, name, to, icon) do
    active = if current_path(conn, %{}) == to, do: "active", else: ""
    link = link [icon(icon), name], to: to, class: "nav-link"
    content_tag :li, link, class: "nav-item #{active}"
  end
end
