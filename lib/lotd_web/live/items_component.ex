defmodule LotdWeb.Live.ItemsComponent do
  use LotdWeb, :live_component

  alias Lotd.Accounts
  alias Lotd.Gallery

  def render(assigns) do
    ~H"""
    <div>
      <.table>
        <:thead>
          <tr>
            <%= if @user && @user.active_character do %>
              <.th condensed order="first"></.th>
            <% end %>
            <.th condensed {if @user && @user.active_character, do: [], else: [order: "first"]}>
              <%= gettext "Name" %>
            </.th>
            <.th class="hidden lg:table-cell text-center" condensed>Mod</.th>
            <.th condensed class="hidden lg:table-cell">
              <Icon.Outline.duplicate class="w-5 h-5"/>
            </.th>
            <%= if @user && @user.moderator do %>
              <.th condensed class="hidden lg:table-cell">
                <.link class="text-indigo-600 hover:text-indigo-900" to={Routes.lotd_path(@socket, :create_item)} target="_blank">
                  <Icon.Outline.plus class="w-5 h-5"/>
                </.link>
              </.th>
            <% end %>
            <.th condensed order="last"><Icon.Outline.external_link class="w-5 h-5"/></.th>
          </tr>
        </:thead>
        <:tbody>
          <%= for item <- @items do %>
            <%= if is_nil(@user) || !@user.hide_aquired_items || !@user.active_character || item.id not in @user.active_character.items do %>
            <tr>
              <%= if @user && @user.active_character do %>
                <.td condensed order="first">
                  <%= checkbox :check, :mark, [
                    class: "focus:ring-indigo-500 h-4 w-4 text-indigo-600 border-gray-300 rounded disabled:opacity-50",
                    checked: item.id in @user.active_character.items,
                    phx_click: "toggle-item",
                    phx_target: @myself,
                    phx_value_id: item.id,
                    id: nil, name: nil
                  ] %>
                </.td>
              <% end %>
              <.td class="truncate" condensed {if @user && @user.active_character, do: [], else: [order: "first"]}><%= item.name %></.td>
              <.td class="hidden lg:table-cell text-center" condensed>
                <%= case Enum.find(@mods, & &1.id == item.mod_id) do %>
                  <% nil -> %>
                  <% %{initials: initials} -> %>
                    <%= if initials do %>
                      <.badge label={initials} />
                    <% end %>
                <% end %>
              </.td>

              <.td condensed class="hidden lg:table-cell">
                <%= if item.replica do %>
                  <Icon.Outline.duplicate class="w-5 h-5"/>
                <% end %>
              </.td>
              <%= if @user && @user.moderator do %>
                <.td condensed class="hidden lg:table-cell">
                  <.link class="text-indigo-600 hover:text-indigo-900" to={Routes.lotd_path(@socket, :update_item, item.id)} target="_blank">
                    <Icon.Outline.pencil class="w-5 h-5"/>
                  </.link>
                </.td>
              <% end %>
              <.td condensed order="last">
                <%= if item.url do %>
                  <.link class="text-indigo-600 hover:text-indigo-900" link_type="a" to={item.url} target="_blank">
                    <Icon.Outline.external_link class="w-5 h-5"/>
                  </.link>
                <% end %>
              </.td>
            </tr>
            <% end %>
          <% end %>
        </:tbody>
      </.table>
    </div>
    """
  end

  def handle_event("toggle-item", %{"id" => id}, socket) do
    item = Gallery.get_item!(id)
    character = socket.assigns.user.active_character
    if item.id in character.items do
      case Accounts.remove_item(character, item) do
        {:ok, character} ->
          user = Accounts.preload_user_associations(socket.assigns.user)
          broadcast("user-id:#{character.user_id}", {:update_user, user})
          {:noreply, socket}
        {:error, _reason} ->
          {:noreply, put_flash(socket, :error, gettext "Could not uncollect item.")}
      end
    else
      case Accounts.collect_item(character, item) do
        {:ok, character} ->
          user = Accounts.preload_user_associations(socket.assigns.user)
          broadcast("user-id:#{character.user_id}", {:update_user, user})
          {:noreply, socket}
        {:error, _reason} ->
          {:noreply, put_flash(socket, :error, gettext "Could not collect item.")}
      end
    end
  end
end
