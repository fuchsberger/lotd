defmodule LotdWeb.Live.ModComponent do
  use LotdWeb, :live_component

  alias Lotd.Gallery
  alias Lotd.Gallery.Mod

  def update(%{mod_id: mod_id, items: items}, socket) do
    socket =
      if mod_id do
        mod = Gallery.get_mod!(mod_id)
        socket
        |> assign(:mod, mod)
        |> assign(:changeset, Gallery.change_mod(mod, %{}))
      else
        socket
        |> assign(:mod, nil)
        |> assign(:changeset, Gallery.change_mod(%Mod{}, %{}))
      end

    {:ok, assign(socket, :items, items)}
  end

  def render(assigns) do
    ~H"""
    <div>
    <.form let={f} for={@changeset} class="space-y-4" phx-change="validate-mod" phx-submit="save-mod" phx-target={@myself}>
      <.card>
        <:body>
          <div class='space-y-3'>
            <.form_field type="text_input" form={f} field={:name}/>

            <.form_field type="text_input" form={f} field={:initials}/>

            <.button type="submit" color="secondary" label={if @mod, do: "Update", else: "Create"} />

            <.button link_type="live_patch" to={Routes.lotd_path(@socket, :mods)} color="white" label="Cancel" />

            <%= if @mod do %>
              <.button type="button" phx-click="delete-mod" color="red" leading_icon="x" label="Delete" phx-target={@myself} data-confirm="Are you absolutely sure?" disabled={Enum.count(@items) > 0} />
            <% end %>
          </div>
        </:body>
      </.card>
      <%= if @mod do %>
        <.table>
          <:thead>
            <tr>
              <.th condensed order="last"><%= gettext "Contains the following Items" %></.th>
            </tr>
          </:thead>
          <:tbody>
            <%= for item <- @items do %>
              <tr>
                <.td condensed order="first"><%= item.name %></.td>
              </tr>
            <% end %>
          </:tbody>
        </.table>
        <% end %>
      </.form>
    </div>
    """
  end

  def handle_event("validate-mod", %{"mod" => params}, socket) do
    changeset =
      if socket.assigns.mod do
        Gallery.change_mod(socket.assigns.mod, params)
      else
        Gallery.change_mod(%Mod{}, params)
      end

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save-mod", %{"mod" => params}, socket) do
    if socket.assigns.mod do
      case Gallery.update_mod(socket.assigns.mod, params) do
        {:ok, _mod} ->
          broadcast("all", {:update_mods, Gallery.list_mods()})
          {:noreply, put_flash(socket, :info, gettext "Mod updated.")}

        {:error, changeset} ->
          {:noreply, socket
          |> assign(:changeset, changeset)
          |> put_flash(:error, gettext "Mod could not be updated.")}
      end
    else
      case Gallery.create_mod(params) do
        {:ok, _mod} ->
          broadcast("all", {:update_mods, Gallery.list_mods()})
          {:noreply, put_flash(socket, :info, gettext "Mod created.")}

        {:error, changeset} ->
          {:noreply, socket
          |> assign(:changeset, changeset)
          |> put_flash(:error, gettext "Mod could not be created.")}
      end
    end
  end

  def handle_event("delete-mod", _params, socket) do
    case Gallery.delete_mod(socket.assigns.mod) do
      {:ok, _mod} ->
        broadcast("all", {:update_mods, Gallery.list_mods()})

        {:noreply, socket
        |> put_flash(:error, gettext "Mod deleted.")
        |> push_patch(to: Routes.lotd_path(socket, :gallery))}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, gettext "Mod could not be deleted.")}
    end
  end
end
