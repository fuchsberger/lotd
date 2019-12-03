defmodule LotdWeb.ItemFormComponent do
  use Phoenix.LiveComponent

  alias Lotd.Museum
  alias Lotd.Museum.Item

  def handle_event("dismiss", _params, socket) do
    {:noreply, assign(socket, error: nil, info: nil)}
  end

  def handle_event("validate", %{"item" => item_params}, socket) do
    item = socket.assigns.changeset.data
    changeset = Museum.change_item(item, item_params)
    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"item" => item_params}, socket) do
    case Museum.save_item(socket.assigns.changeset.data, item_params) do
      {:ok, item } ->
        {:noreply, assign(socket,
          changeset: Museum.change_item(%Item{}, item_params),
          info: "#{item.name} was saved.",
          error: nil,
          submitted: false
        )}
      {:error, changeset } ->
        {:noreply, assign(socket,
          changeset: changeset,
          error: "Please check your inputs.",
          info: nil,
          submitted: true
        )}
    end
  end

  def render(assigns) do
    Phoenix.View.render(LotdWeb.ItemView, "form.html", assigns)
  end
end
