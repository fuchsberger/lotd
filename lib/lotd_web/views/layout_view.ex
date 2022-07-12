defmodule LotdWeb.LayoutView do
  use LotdWeb, :view

  defp main_menu_items(live_action) do
    [
      # {action, label, icon (outline), active?}
      {:gallery, gettext("Museum"), "home", live_action == :gallery},
      {:locations, gettext("Locations"), "map", live_action == :locations},
      {:mods, gettext("Mods"), "star", live_action == :mods}
    ]
  end

  # lists rooms
  defp secondary_items(:gallery) do
    [
      # {action, label, active?}
      # {:home, gettext("Eigenschaften"), live_action == :home},
    ]
  end

  defp secondary_items(_live_action) do
    [
      # {action, label, active?}
      # {:home, gettext("Eigenschaften"), live_action == :home},
    ]
  end

  defp desktop_item_attrs(true), do: [class: "w-full text-left bg-gray-200 text-gray-900 group flex items-center px-3 py-2 text-sm font-medium rounded-md", aria_current: "page"]

  defp desktop_item_attrs(false), do: [class: "w-full text-left text-gray-600 hover:bg-gray-50 group flex items-center px-3 py-2 text-sm font-medium rounded-md"]

  defp desktop_item_class(false), do: "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300 inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium"

  defp desktop_item_class(true), do: "border-indigo-500 text-gray-900 inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium"

  defp menu_items(conn) do
    items =
      [
        {gettext("About"), Routes.page_path(conn, :about)},
        {gettext("Gallery"), Routes.item_path(conn, :index)},
        {gettext("Mods"), Routes.mod_path(conn, :index)}
      ]

    if is_nil(conn.assigns.current_user) do
      items
    else
      items ++ [{gettext("Characters"), Routes.item_path(conn, :index)}]
    end
    |> Enum.map(fn {label, path} ->
        {label, path, Phoenix.Controller.current_path(conn) == path}
      end)
  end

  defp mobile_item_attrs(true), do: [class: "w-full text-left bg-gray-100 text-gray-900 block rounded-md py-2 px-3 text-base font-medium truncate", aria_current: "page"]

  defp mobile_item_attrs(false), do: [class: "w-full text-left hover:bg-gray-50 block rounded-md py-2 px-3 text-base font-medium truncate"]

  defp mobile_item_class(false), do: "border-transparent text-gray-600 hover:bg-gray-50 hover:border-gray-300 hover:text-gray-800 block pl-3 pr-4 py-2 border-l-4 text-base font-medium"

  defp mobile_item_class(true), do: "bg-indigo-50 border-indigo-500 text-indigo-700 block pl-3 pr-4 py-2 border-l-4 text-base font-medium"

  defp mobile_secondary_attrs(true), do: [class: "block rounded-md py-2 px-3 text-base font-medium text-gray-900 hover:bg-gray-50", aria_current: "page"]

  defp mobile_secondary_attrs(false), do: [class: "block rounded-md py-2 px-3 text-base font-medium text-gray-500 hover:bg-gray-50 hover:text-gray-900 w-full text-left"]
end
