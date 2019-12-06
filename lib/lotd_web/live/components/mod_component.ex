defmodule LotdWeb.ModComponent do
  use Phoenix.LiveComponent

  import Phoenix.HTML.Form, only: [checkbox: 3]
  import LotdWeb.ViewHelpers, only: [link_title: 1]

  alias Lotd.{Accounts, Museum}

  def preload(list_of_assigns) do

    list_of_ids = Enum.map(list_of_assigns, & &1.id)

    mods = Museum.list_mods(list_of_ids)
    user = List.first(list_of_assigns).user

    mods = unless is_nil(user) do
      character_mod_ids = Accounts.get_character_mod_ids(user.active_character)
      mods
      |> Enum.map(fn {k, v} -> {k, Map.put(v, :active, Enum.member?(character_mod_ids, k))} end)
      |> Map.new()
    else
      Map.new(mods)
    end

    Enum.map(list_of_assigns, fn assigns -> Map.put(assigns, :mod, mods[assigns.id]) end)
  end

  def render(assigns) do
    ~L"""
      <tr id='row<%= @mod.id %>'>
        <%= unless is_nil(@user) do %>
          <td>
            <a phx-click='toggle_active'>
              <i class='<%= icon_active(@mod.active) %>'></i>
            </a>
          </td>
        <% end %>
        <td class='font-weight-bold' data-sort='<%= @mod.name %>'>
          <%= link_title(@mod) %>
        </td>
        <td><%= @mod.filename %></td>
        <td><%= Enum.count(@mod.items) %></td>
        <td><%= Enum.count(@mod.locations) %></td>
        <td><%= Enum.count(@mod.quests) %></td>
        <%= if @user && @user.moderator do %>
          <td><a class='icon-pencil'></a></td>
        <% end %>
        <td class='control'></td>
      </tr>
    """
  end

  def handle_event("toggle_active", _params, socket) do

    character = socket.assigns.user.active_character
    mod = socket.assigns.mod

    if mod.active,
      do: Accounts.update_character_remove_mod(character, mod.id),
      else: Accounts.update_character_add_mod(character, mod)

    send self(), {:updated_mod, mod}

    # {:noreply, assign(socket, :mod, Map.put( mod, :active, !mod.active ))}
    {:noreply, socket}
  end

  defp icon_active(active) do
    if active, do: "icon-ok-squared", else: "icon-plus-squared-alt"
  end
end
