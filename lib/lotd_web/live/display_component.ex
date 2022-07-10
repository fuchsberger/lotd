defmodule LotdWeb.Live.DisplayComponent do
  use LotdWeb, :live_component

  alias Lotd.Gallery
  alias Lotd.Gallery.Display

  def update(%{display_id: display_id, room_id: room_id, room_options: room_options, items: items}, socket) do
    socket =
      if display_id do
        display = Gallery.get_display!(display_id)
        socket
        |> assign(:display, display)
        |> assign(:changeset, Gallery.change_display(display, %{}))
      else
        socket
        |> assign(:display, nil)
        |> assign(:changeset, Gallery.change_display(%Display{}))
      end

    {:ok, socket
    |> assign(:items, items)
    |> assign(:room_id, room_id)
    |> assign(:room_options, room_options)}
  end

  def render(assigns) do
    ~H"""
    <div>
    <.form let={f} for={@changeset} class="space-y-4" phx-change="validate-display" phx-submit="save-display" phx-target={@myself}>
      <.card>
        <:body>
          <div class='space-y-3'>
            <.form_field type="text_input" form={f} field={:name}/>

            <.form_field type="select" options={@room_options} form={f} field={:room_id}/>

            <.button type="submit" color="secondary" label={if @display, do: "Update", else: "Create"} />

            <.button link_type="live_patch" to={Routes.lotd_path(@socket, :gallery)} color="white" label="Cancel" />

            <%= if @display do %>
              <.button type="button" phx-click="delete-display" color="red" leading_icon="x" label="Delete" phx-target={@myself} data-confirm="Are you absolutely sure?" disabled={Enum.count(@items) > 0} />
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
          broadcast("all", {:update_displays, Gallery.list_displays()})
          {:noreply, put_flash(socket, :info, gettext "Display updated.")}

        {:error, changeset} ->
          {:noreply, socket
          |> assign(:changeset, changeset)
          |> put_flash(:error, gettext "Display could not be updated.")}
      end
    else
      case Gallery.create_display(params) do
        {:ok, _display} ->
          broadcast("all", {:update_displays, Gallery.list_displays()})
          {:noreply, put_flash(socket, :info, gettext "Display created.")}

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
        broadcast("all", {:update_displays, Gallery.list_displays()})

        {:noreply, socket
        |> put_flash(:error, gettext "Display deleted.")
        |> push_patch(to: Routes.lotd_path(socket, :gallery))}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, gettext "Display could not be deleted.")}
    end
  end
end
