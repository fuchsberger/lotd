defmodule LotdWeb.Live.DisplayComponent do
  use LotdWeb, :live_component

  alias Lotd.Gallery
  alias Lotd.Gallery.Display

  def update(%{display_id: display_id, room_id: room_id, items: items}, socket) do
    if display_id do
      display = Gallery.get_display!(display_id)
      {:ok, socket
      |> assign(:display, display)
      |> assign(:changeset, Gallery.change_display(display, %{}))
      |> assign(:items, items)
      |> assign(:room_id, room_id)}
    else
      {:ok, socket
      |> assign(:display, nil)
      |> assign(:changeset, Gallery.change_display(%Display{}))
      |> assign(:items, items)
      |> assign(:room_id, room_id)}
    end
  end

  def render(assigns) do
    ~H"""
    <div>
    <.form let={f} for={@changeset} class="space-y-4" phx-change="validate-display" phx-submit="save-display" phx-target={@myself}>
      <.card>
        <:body>
          <div class="flex justify-between items-center gap-x-3">
            <div class="grow">
              <.form_field type="text_input" form={f} field={:name}/>
            </div>
            <div class="flex-shrink-0 pt-4">
              <.button type="submit" color="secondary" label={if @display, do: "Update", else: "Create"} />
            </div>
            <%= if @display do %>
              <div class="flex-shrink-0 pt-4">
                <.button type="button" phx-click="delete-display" color="red" leading_icon="x" label="Delete" phx-target={@myself} data-confirm="Are you absolutely sure?" disabled={Enum.count(@items) > 0} />
              </div>
            <% end %>
          </div>
        </:body>
      </.card>
      <%= if @display do %>
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

  def handle_event("validate-display", %{"display" => params}, socket) do
    changeset =
      if socket.assigns.display do
        Gallery.change_display(socket.assigns.display, params)
      else
        Gallery.change_display(%Display{}, params)
      end

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save-display", %{"display" => params}, socket) do
    params = Map.put(params, "room_id", socket.assigns.room_id)

    if socket.assigns.display do
      case Gallery.update_display(socket.assigns.display, params) do
        {:ok, _display} ->
          {:noreply, socket
          |> put_flash(:info, gettext "Display updated.")
          |> push_patch(to: Routes.lotd_path(socket, :update_display))}

        {:error, changeset} ->
          {:noreply, socket
          |> assign(:changeset, changeset)
          |> put_flash(:error, gettext "Display could not be updated.")}
      end
    else
      case Gallery.create_display(params) do
        {:ok, _display} ->
          {:noreply, socket
          |> put_flash(:info, gettext "Display created.")
          |> push_redirect(to: Routes.lotd_path(socket, :gallery))}

        {:error, changeset} ->
          {:noreply, socket
          |> assign(:changeset, changeset)
          |> put_flash(:error, gettext "Display could not be created.")}
      end
    end
  end

  def handle_event("delete-display", _params, socket) do
    case Gallery.delete_display(socket.assigns.display) do
      {:ok, _display} ->
        {:noreply, socket
        |> put_flash(:error, gettext "Display deleted.")
        |> push_patch(to: Routes.lotd_path(socket, :gallery))}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, gettext "Display could not be deleted.")}
    end
  end
end
