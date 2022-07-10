defmodule LotdWeb.Live.CharacterComponent do
  use LotdWeb, :live_component

  alias Lotd.Accounts
  alias Lotd.Accounts.Character
  alias Lotd.Gallery

  def update(%{action: action, mods: mods, user: user}, socket) do
    changeset =
      if action == :create do
        Accounts.change_character(%Character{})
      else
        Accounts.change_character(user.active_character, %{})
      end

    {:ok, socket
    |> assign(:action, action)
    |> assign(:changeset, changeset)
    |> assign(:mods, mods)
    |> assign(:user, user)}
  end

  def render(assigns) do
    ~H"""
    <div>
    <.form let={f} for={@changeset} class="space-y-4" phx-change="validate-character" phx-submit="save-character" phx-target={@myself}>
      <.card>
        <:body>
          <div class="flex justify-between items-center gap-x-3">
            <div class="grow">
              <.form_field type="text_input" form={f} field={:name}/>
            </div>
            <div class="flex-shrink-0 pt-4">
              <.button type="submit" color="secondary" label={if @action == :create, do: "Create Character", else: "Update #{@user.active_character.name}"} />
            </div>
            <%= if @action == :update do %>
              <div class="flex-shrink-0 pt-4">
                <.button type="button" phx-click="delete-character" color="red" leading_icon="x" label="Delete" phx-target={@myself} data-confirm="Are you absolutely sure?" />
              </div>
            <% end %>
          </div>
        </:body>
      </.card>
      <%= if @action == :update do %>
        <.table>
          <:thead>
            <tr>
              <.th condensed order="first">
                <%= checkbox :check, :mark, [
                  class: "focus:ring-indigo-500 h-4 w-4 text-indigo-600 border-gray-300 rounded disabled:opacity-50",
                  checked: Enum.count(@mods) == Enum.count(@user.active_character.mods), phx_click: "toggle-all-mods",
                  phx_target: @myself,
                  id: nil, name: nil
                ] %>
              </.th>
              <.th condensed order="last"><%= gettext "Activate / show the following Mods:" %></.th>
            </tr>
          </:thead>
          <:tbody>
            <%= for mod <- @mods do %>
              <tr>
                <.td condensed order="first" class="first w-12 sm:w-16">
                  <%= checkbox :check, :mark, [
                    class: "focus:ring-indigo-500 h-4 w-4 text-indigo-600 border-gray-300 rounded disabled:opacity-50",
                    checked: mod.id in @user.active_character.mods, phx_click: "toggle-mod",
                    phx_target: @myself,
                    phx_value_id: mod.id,
                    id: nil, name: nil
                  ] %>
                </.td>
                <.td condensed order="last"><%= mod.name %></.td>
              </tr>
            <% end %>
          </:tbody>
        </.table>
        <% end %>
      </.form>
    </div>
    """
  end

  def handle_event("validate-character", %{"character" => params}, socket) do
    changeset =
      if socket.assigns.action == :create do
        Accounts.change_character(%Character{}, params)
      else
        Accounts.change_character(socket.assigns.user.active_character, params)
      end

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save-character", %{"character" => params}, socket) do

    if socket.assigns.action == :create do
      case Accounts.create_character(socket.assigns.user, params) do
        {:ok, character} ->
          case Accounts.update_user(socket.assigns.user, %{active_character_id: character.id}) do
            {:ok, _user} ->
              {:noreply, socket
              |> put_flash(:info, gettext "Character created and activated.")
              |> push_redirect(to: Routes.lotd_path(socket, :update_character))}

            {:error, _reason} ->
              {:noreply, put_flash(socket, :error, gettext "Character could not be created")}
          end
        {:error, _reason} ->
          {:noreply, put_flash(socket, :error, gettext "Character could not be created")}
      end
    else
      case Accounts.update_character(socket.assigns.user.active_character, params) do
        {:ok, character} ->
          user = Accounts.preload_user_associations(socket.assigns.user)
          broadcast("user-id:#{character.user_id}", {:update_user, user})
          {:noreply, socket
          |> put_flash(:info, gettext "Character updated.")
          |> push_redirect(to: Routes.lotd_path(socket, :mods))}

        {:error, _reason} ->
          {:noreply, put_flash(socket, :error, gettext "Character could not be updated")}
      end
    end
  end

  def handle_event("delete-character", _params, socket) do
    case Accounts.delete_character(socket.assigns.user.active_character) do
      {:ok, character} ->
        user = Accounts.preload_user_associations(socket.assigns.user)
        broadcast("user-id:#{character.user_id}", {:update_user, user})
        {:noreply, socket
        |> put_flash(:error, gettext "Character deleted.")
        |> push_patch(to: Routes.lotd_path(socket, :mods))}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, gettext "Character could not be deleted.")}
    end
  end

  def handle_event("toggle-all-mods", _params, socket) do
    character = socket.assigns.user.active_character
    if Enum.count(socket.assigns.mods) == Enum.count(character.mods) do
      case Accounts.deactivate_all_mods(character) do
        {:ok, character} ->
          user = Accounts.preload_user_associations(socket.assigns.user)
          broadcast("user-id:#{character.user_id}", {:update_user, user})
          {:noreply, socket}
        {:error, _reason} ->
          {:noreply, put_flash(socket, :error, gettext "Could not deactivate all mods.")}
      end

    else
      case Accounts.activate_all_mods(character) do
        {:ok, character} ->
          user = Accounts.preload_user_associations(socket.assigns.user)
          broadcast("user-id:#{character.user_id}", {:update_user, user})
          {:noreply, socket}
        {:error, _reason} ->
          {:noreply, put_flash(socket, :error, gettext "Could not activate all mods.")}
      end
    end
  end

  def handle_event("toggle-mod", %{"id" => id}, socket) do
    mod = Gallery.get_mod!(id)
    character = socket.assigns.user.active_character
    if mod.id in character.mods do
      case Accounts.deactivate_mod(character, mod) do
        {:ok, character} ->
          user = Accounts.preload_user_associations(socket.assigns.user)
          broadcast("user-id:#{character.user_id}", {:update_user, user})
          {:noreply, socket}
        {:error, _reason} ->
          {:noreply, put_flash(socket, :error, gettext "Could not deactivate mod.")}
      end

    else
      case Accounts.activate_mod(character, mod) do
        {:ok, character} ->
          user = Accounts.preload_user_associations(socket.assigns.user)
          broadcast("user-id:#{character.user_id}", {:update_user, user})
          {:noreply, socket}
        {:error, _reason} ->
          {:noreply, put_flash(socket, :error, gettext "Could not activate mod.")}
      end
    end
  end
end
