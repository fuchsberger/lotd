defmodule LotdWeb.LayoutView do
  use LotdWeb, :view

  import Phoenix.Controller, only: [controller_module: 1]

  def authenticated?(conn), do: conn.assigns.current_user

  def logout_button(conn) do
    nexus_icon = raw "<span class='icon is-small'><i class='nexus-icon'></i></span>"
    username = content_tag :strong, conn.assigns.current_user.nexus_name

    link [nexus_icon, username, icon("off")],
      to: Routes.session_path(conn, :delete, conn.assigns.current_user.id),
      method: "delete",
      class: "button",
      title: "Logout"
  end

  def menu_link(conn, module, title) do

    current_module = conn.path_info |> List.first() |> String.to_atom()
    class = if current_module == module, do: "is-active", else: ""

    path = case module do
      :user -> Routes.user_path(conn, :index)
      _ -> Routes.page_path(conn, :index)
    end

    content_tag :li, link(title, to: path), class: class
  end

  def unique_view_name(view_module, view_template) do
    [action, "html"] = String.split(view_template, ".")

    view_module
    |> Phoenix.Naming.resource_name()
    |> String.replace("_view", "/#{action}")
  end
end
