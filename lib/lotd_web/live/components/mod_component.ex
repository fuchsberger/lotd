defmodule LotdWeb.ModComponent do
  use Phoenix.LiveComponent

  import Phoenix.HTML.Form, only: [checkbox: 3]
  import LotdWeb.ViewHelpers, only: [link_title: 1]

  alias Lotd.{Accounts, Museum}

  def render(assigns) do
    ~L"""
      <tr>
        <%= if Map.has_key?(@mod, :active) do %>
          <td class='text-center'>
            <a phx-click='toggle_active' phx-value-id='<%= @mod.id %>'>
              <i class='<%= icon_active(@mod.active) %>'></i>
            </a>
          </td>
        <% end %>
        <td class='font-weight-bold' data-sort='<%= @mod.name %>'><%= link_title(@mod) %></td>
        <td><%= @mod.filename %></td>
        <td><%= Enum.count(@mod.items) %></td>
        <td><%= Enum.count(@mod.locations) %></td>
        <td><%= Enum.count(@mod.quests) %></td>
        <%= if @moderator do %><td><a class='icon-pencil'></a></td><% end %>
      </tr>
    """
  end

  defp icon_active(active) do
    if active, do: "icon-ok-squared", else: "icon-plus-squared-alt"
  end
end
