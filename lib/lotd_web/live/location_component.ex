defmodule LotdWeb.Live.LocationComponent do
  use LotdWeb, :live_component

  alias Lotd.Gallery
  alias Lotd.Gallery.Location

  def update(%{location_id: location_id, region_id: region_id, region_options: region_options, items: items}, socket) do
    socket =
      if location_id do
        location = Gallery.get_location!(location_id)
        socket
        |> assign(:location, location)
        |> assign(:changeset, Gallery.change_location(location, %{}))
      else
        socket
        |> assign(:location, nil)
        |> assign(:changeset, Gallery.change_location(%Location{}))
      end

    {:ok, socket
    |> assign(:items, items)
    |> assign(:region_id, region_id)
    |> assign(:region_options, region_options)}
  end

  def render(assigns) do
    ~H"""
    <div>
    <.form let={f} for={@changeset} class="space-y-4" phx-change="validate-location" phx-submit="save-location" phx-target={@myself}>
      <.card>
        <:body>
          <div class='space-y-3'>
            <.form_field type="text_input" form={f} field={:name}/>

            <.form_field type="select" options={@region_options} form={f} field={:region_id}/>

            <.button type="submit" color="secondary" label={if @location, do: "Update", else: "Create"} />

            <.button link_type="live_patch" to={Routes.lotd_path(@socket, :locations)} color="white" label="Cancel" />

            <%= if @location do %>
              <.button type="button" phx-click="delete-location" color="red" leading_icon="x" label="Delete" phx-target={@myself} data-confirm="Are you absolutely sure?" disabled={Enum.count(@items) > 0} />
            <% end %>
          </div>
        </:body>
      </.card>
      <%= if @location do %>
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

  def handle_event("validate-location", %{"location" => params}, socket) do
    changeset =
      if socket.assigns.location do
        Gallery.change_location(socket.assigns.location, params)
      else
        Gallery.change_location(%Location{}, params)
      end

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save-location", %{"location" => params}, socket) do
    if socket.assigns.location do
      case Gallery.update_location(socket.assigns.location, params) do
        {:ok, _location} ->
          broadcast("all", {:update_locations, Gallery.list_locations()})
          {:noreply, put_flash(socket, :info, gettext "Location updated.")}

        {:error, changeset} ->
          {:noreply, socket
          |> assign(:changeset, changeset)
          |> put_flash(:error, gettext "Location could not be updated.")}
      end
    else
      case Gallery.create_location(params) do
        {:ok, _location} ->
          {:noreply, socket
          |> put_flash(:info, gettext "Location created.")
          |> push_redirect(to: Routes.lotd_path(socket, :locations))}

        {:error, changeset} ->
          {:noreply, socket
          |> assign(:changeset, changeset)
          |> put_flash(:error, gettext "Location could not be created.")}
      end
    end
  end

  def handle_event("delete-location", _params, socket) do
    case Gallery.delete_location(socket.assigns.location) do
      {:ok, _location} ->
        broadcast("all", {:update_locations, Gallery.list_locations()})

        {:noreply, socket
        |> put_flash(:error, gettext "Location deleted.")
        |> push_patch(to: Routes.lotd_path(socket, :locations))}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, gettext "Location could not be deleted.")}
    end
  end
end
