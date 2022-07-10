defmodule LotdWeb.Live.ItemsComponent do
  use LotdWeb, :live_component

  def render(assigns) do
    ~H"""
    <div>
      <.table>
        <:thead>
          <tr>
            <%= if @character do %>
              <.th condensed order="first">
                <%= checkbox :check, :mark, [class: "focus:ring-indigo-500 h-4 w-4 text-indigo-600 border-gray-300 rounded disabled:opacity-50", disabled: true] %>
              </.th>
            <% end %>
            <.th condensed order="first"><%= gettext "Name" %></.th>
            <.th condensed><Icon.Outline.duplicate class="w-5 h-5"/></.th>
            <.th condensed order="last"><Icon.Outline.external_link class="w-5 h-5"/></.th>
          </tr>
        </:thead>
        <:tbody>
          <%= for item <- @items do %>
            <tr>
              <%= if @character do %>
                <.th condensed order="first">
                  <.checkbox />
                </.th>
              <% end %>
              <.td condensed order="first"><%= item.name %></.td>
              <.td condensed order="last">
                <%= if item.replica do %>
                  <Icon.Outline.duplicate class="w-5 h-5"/>
                <% end %>
              </.td>
              <.td condensed order="last">
                <%= if item.url do %>
                  <.link class="text-indigo-600 hover:text-indigo-900" link_type="a" to={item.url} target="_blank">
                    <Icon.Outline.external_link class="w-5 h-5"/>
                  </.link>
                <% end %>
              </.td>
            </tr>
          <% end %>
        </:tbody>
      </.table>
    </div>
    """
  end
end
