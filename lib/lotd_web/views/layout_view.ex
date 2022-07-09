defmodule LotdWeb.LayoutView do
  use LotdWeb, :view

  import Phoenix.Controller, only: [current_path: 2]

  def logout_button(conn) do
    link [icon("logout"), conn.assigns.current_user.username ],
      to: Routes.session_path(conn, :delete, conn.assigns.current_user.id),
      method: "delete",
      id: "logout-button",
      class: "nav-link font-weight-bold",
      data_toggle: "tooltip",
      title: "Logout"
  end

  defp main_menu_items(live_action) do
    [
      # {action, label, icon (outline), active?, show?}
      {:home, gettext("Spielprotokoll"), "home", live_action == :home, true},
      {:group, gettext("Kampf"), "users", live_action == :group, true},
      {:skills, gettext("Talente"), "star", live_action in [:skills, :skill], true},
      {:map, gettext("Karte"), "map", live_action == :map, true}
    ]
  end

  defp mobile_item_attrs(true), do: [class: "bg-gray-100 text-gray-900 block rounded-md py-2 px-3 text-base font-medium", aria_current: "page"]

  defp mobile_item_attrs(false), do: [class: "hover:bg-gray-50 block rounded-md py-2 px-3 text-base font-medium"]
end
