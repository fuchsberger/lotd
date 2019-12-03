defmodule LotdWeb.LayoutView do
  use LotdWeb, :view

  def logout_button(socket) do
    link [icon("off"), "Logout"],
      to: Routes.session_path(socket, :delete, socket.assigns.user.id),
      method: "delete",
      id: "logout-button",
      class: "dropdown-item"
  end
end
