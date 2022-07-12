defmodule LotdWeb.ModView do
  use LotdWeb, :view

  def static_checkbox(assigns) do
    ~H"""
    <%= if @active do %>
      <input type="checkbox" class="absolute cursor-pointer left-4 top-1/2 -mt-2 h-4 w-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-500" checked>
    <% else %>
      <input type="checkbox" class="absolute cursor-pointer left-4 top-1/2 -mt-2 h-4 w-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-500">
    <% end %>
    """
  end
end
