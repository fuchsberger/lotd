defmodule LotdWeb.LayoutView do
  use LotdWeb, :view

  import Phoenix.Controller, only: [action_name: 1, get_flash: 1]

  defp desktop_item_class(false), do: "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300 inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium"

  defp desktop_item_class(true), do: "border-indigo-500 text-gray-900 inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium"

  defp menu_items(conn) do
    items =
      [
        {gettext("About"), Routes.page_path(conn, :about)},
        {gettext("Items"), Routes.page_path(conn, :item)},
        {gettext("Mods"), Routes.page_path(conn, :mod)}
      ]

    items = if is_nil(conn.assigns.current_user),
      do: items,
      else: items ++ [{gettext("Characters"), Routes.page_path(conn, :character)}]

    Enum.map(items, fn {label, path} ->
      {label, path, Phoenix.Controller.current_path(conn) == path}
    end)
  end

  defp more_items(conn), do: [
    {gettext("Displays"), Routes.page_path(conn, :display)},
    {gettext("Locations"), Routes.page_path(conn, :location)},
    {gettext("Regions"), Routes.page_path(conn, :region)},
    {gettext("Rooms"), Routes.page_path(conn, :room)}
  ]
  |> Enum.map(fn {label, path} ->
    {label, path, Phoenix.Controller.current_path(conn) == path}
  end)

  defp mobile_item_class(false), do: "border-transparent text-gray-600 hover:bg-gray-50 hover:border-gray-300 hover:text-gray-800 block pl-3 pr-4 py-2 border-l-4 text-base font-medium"

  defp mobile_item_class(true), do: "bg-indigo-50 border-indigo-500 text-indigo-700 block pl-3 pr-4 py-2 border-l-4 text-base font-medium"

  defp more_button_attrs(true), do: [
    class: "pt-6 pb-5 inline-flex border-indigo-500 text-gray-900 items-center px-1 border-b-2 text-sm font-medium",
    area_expanded: true
  ]

  defp more_button_attrs(false), do: [
    class: "pt-6 pb-5 inline-flex border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300 items-center px-1 border-b-2 text-sm font-medium",
    area_expanded: false
  ]

  defp dropdown_item_class(true), do: "bg-gray-100 text-gray-900 block px-4 py-2 text-sm"
  defp dropdown_item_class(false), do: "text-gray-700 block px-4 py-2 text-sm"
end
