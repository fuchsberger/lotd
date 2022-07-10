defmodule LotdWeb.Live.ItemComponent do
  use LotdWeb, :live_component

  alias Lotd.Gallery
  alias Lotd.Gallery.Item

  def update(%{item_id: item_id, display_id: display_id, display_options: display_options, location_id: location_id, location_options: location_options, mod_id: mod_id, mod_options: mod_options}, socket) do
    params = %{
      display_id: display_id,
      location_id: location_id,
      mod_id: mod_id
    }

    socket =
      if item_id do
        item = Gallery.get_item!(item_id)
        socket
        |> assign(:item, item)
        |> assign(:changeset, Gallery.change_item(item, params))
      else
        socket
        |> assign(:item, nil)
        |> assign(:changeset, Gallery.change_item(%Item{}, params))
      end

    {:ok, socket
    |> assign(:display_options, display_options)
    |> assign(:location_options, location_options)
    |> assign(:mod_options, mod_options)}
  end

  def render(assigns) do
    ~H"""
    <div>
    <.form let={f} for={@changeset} class="space-y-4" phx-change="validate-item" phx-submit="save-item" phx-target={@myself}>
      <.card>
        <:body>
          <div class='space-y-3'>
            <.form_field type="text_input" form={f} field={:name}/>

            <.form_field type="url_input" form={f} field={:url}/>

            <.form_field type="select" options={@display_options} form={f} field={:display_id}/>

            <.form_field type="select" options={@location_options} form={f} field={:location_id}/>

            <.form_field type="select" options={@mod_options} form={f} field={:mod_id}/>

            <.form_field type="checkbox" form={f} field={:replica}/>

            <.button type="submit" color="secondary" label={if @item, do: "Update", else: "Create"} />

            <.button link_type="live_patch" to={Routes.lotd_path(@socket, :gallery)} color="white" label="Cancel" />

            <%= if @item do %>
              <.button type="button" phx-click="delete-item" color="red" leading_icon="x" label="Delete" phx-target={@myself} data-confirm="Are you absolutely sure?" />
            <% end %>
          </div>
        </:body>
      </.card>
      </.form>
    </div>
    """
  end

  def handle_event("validate-item", %{"item" => params}, socket) do
    changeset =
      if socket.assigns.item do
        Gallery.change_item(socket.assigns.item, params)
      else
        Gallery.change_item(%Item{}, params)
      end

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save-item", %{"item" => params}, socket) do
    if socket.assigns.item do
      case Gallery.update_item(socket.assigns.item, params) do
        {:ok, _item} ->
          broadcast("all", {:update_items, Gallery.list_items()})
          {:noreply, put_flash(socket, :info, gettext "Item updated.")}

        {:error, changeset} ->
          {:noreply, socket
          |> assign(:changeset, changeset)
          |> put_flash(:error, gettext "Item could not be updated.")}
      end
    else
      case Gallery.create_item(params) do
        {:ok, _item} ->
          broadcast("all", {:update_items, Gallery.list_items()})
          {:noreply, put_flash(socket, :info, gettext "Item created.")}

        {:error, changeset} ->
          {:noreply, socket
          |> assign(:changeset, changeset)
          |> put_flash(:error, gettext "Item could not be created.")}
      end
    end
  end

  def handle_event("delete-item", _params, socket) do
    case Gallery.delete_item(socket.assigns.item) do
      {:ok, _item} ->
        broadcast("all", {:update_items, Gallery.list_items()})

        {:noreply, socket
        |> put_flash(:error, gettext "Item deleted.")
        |> push_patch(to: Routes.lotd_path(socket, :gallery))}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, gettext "Item could not be deleted.")}
    end
  end
end
