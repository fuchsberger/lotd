defmodule LotdWeb.LayoutView do
  use LotdWeb, :view

  import Phoenix.Controller, only: [current_path: 2]

  def logout_button(conn) do
    name = content_tag :span, conn.assigns.current_user.name, class: "d-md-none d-xl-inline-block"
    link [icon("logout"), name],
      to: Routes.session_path(conn, :delete, conn.assigns.current_user.id),
      method: "delete",
      id: "logout-button",
      class: "nav-link font-weight-bold",
      data_toggle: "tooltip",
      title: "Logout #{conn.assigns.current_user.name}"
  end

  def nav_item(conn, name, to, icon) do
    active = if current_path(conn, %{}) == to, do: "active", else: ""
    link = link [icon(icon), name], to: to, class: "nav-link"
    content_tag :li, link, class: "nav-item #{active}"
  end

  def view_name(view_module, view_template) do
    view = Phoenix.Naming.resource_name(view_module, "View")
    [action, "html"] =  String.split(view_template, ".")
    "#{view}/#{action}"
  end
end
