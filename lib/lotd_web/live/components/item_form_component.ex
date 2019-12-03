defmodule LotdWeb.ItemFormComponent do
  use Phoenix.LiveComponent
  use Phoenix.HTML

  alias Lotd.Gallery

  def handle_event("validate", %{"item" => item_params}, socket) do
    item = socket.assigns.changeset.data
    changeset = Gallery.change_item(item, item_params)
    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"item" => item_params}, socket) do
    item = socket.assigns.changeset.data
    changeset = Gallery.change_item(item, item_params)
    {:noreply, assign(socket, changeset: changeset, submitted: true)}
  end

  def render(assigns) do
    Phoenix.View.render(LotdWeb.ItemView, "form.html", assigns)
  end
end
