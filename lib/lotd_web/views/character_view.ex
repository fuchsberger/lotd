defmodule LotdWeb.CharacterView do
  use LotdWeb, :view

  defp static_radio(assigns) do
    ~H"""
    <%= if @active do %>
      <input type="radio" class="focus:ring-indigo-500 h-4 w-4 text-indigo-600 border-gray-300" checked>
    <% else %>
      <input type="radio" class="focus:ring-indigo-500 h-4 w-4 text-indigo-600 border-gray-300">
    <% end %>
    """
  end

  defp title(:create), do: gettext "Create Character"
  defp title(:update), do: gettext "Update Character"
  defp title(:delete), do: gettext "Delete Character"
end
