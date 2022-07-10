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

  defp mobile_item_attrs(true), do: [class: "w-full text-left bg-gray-100 text-gray-900 block rounded-md py-2 px-3 text-base font-medium truncate", aria_current: "page"]

  defp mobile_item_attrs(false), do: [class: "w-full text-left hover:bg-gray-50 block rounded-md py-2 px-3 text-base font-medium truncate"]

  defp mobile_secondary_attrs(true), do: [class: "block rounded-md py-2 px-3 text-base font-medium text-gray-900 hover:bg-gray-50", aria_current: "page"]

  defp mobile_secondary_attrs(false), do: [class: "block rounded-md py-2 px-3 text-base font-medium text-gray-500 hover:bg-gray-50 hover:text-gray-900 w-full text-left"]
end
