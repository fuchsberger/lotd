defmodule LotdWeb.LayoutView do
  use LotdWeb, :view

  import Phoenix.Controller, only: [get_flash: 1]

  defp desktop_item_class(false), do: "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300 inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium"

  defp desktop_item_class(true), do: "border-indigo-500 text-gray-900 inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium"

  defp menu_items(conn) do
    items =
      [
        {gettext("About"), Routes.page_path(conn, :about)},
        {gettext("Items"), Routes.page_path(conn, :item)},
        {gettext("Mods"), Routes.page_path(conn, :mod)}
      ]

    if is_nil(conn.assigns.current_user) do
      items
    else
      items ++ [{gettext("Characters"), Routes.page_path(conn, :character)}]
    end
    |> Enum.map(fn {label, path} ->
        {label, path, Phoenix.Controller.current_path(conn) == path}
      end)
  end

  defp mobile_item_class(false), do: "border-transparent text-gray-600 hover:bg-gray-50 hover:border-gray-300 hover:text-gray-800 block pl-3 pr-4 py-2 border-l-4 text-base font-medium"

  defp mobile_item_class(true), do: "bg-indigo-50 border-indigo-500 text-indigo-700 block pl-3 pr-4 py-2 border-l-4 text-base font-medium"
end
