defmodule LotdWeb.LayoutView do
  use LotdWeb, :view

  def logout_button(conn) do
    link [icon("off"), "Logout"],
      to: Routes.session_path(conn, :delete, user(conn).id),
      method: "delete",
      id: "logout-button",
      class: "dropdown-item",
      title: "Logout #{user(conn).nexus_name}"
  end
end
