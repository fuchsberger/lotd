defmodule LotdWeb.ItemFormComponent do
  use Phoenix.LiveComponent

  alias Lotd.Gallery

  def handle_event("dismiss", _params, socket) do
    {:noreply, assign(socket, error: nil, info: nil)}
  end

  def handle_event("validate", %{"item" => item_params}, socket) do
    item = socket.assigns.changeset.data
    changeset = Gallery.change_item(item, item_params)
    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"item" => item_params}, socket) do
    item = socket.assigns.changeset.data
    changeset = Gallery.change_item(item, item_params)

    case Gallery.save_item(changeset) do
      {:ok, item } ->
        {:noreply, assign(socket, changeset: changeset, info: "#{item.name} was saved.", submitted: false)}
      {:error, changeset } ->
        {:noreply, assign(socket, changeset: changeset, error: "Please check your inputs.", submitted: true)}
    end
  end

  def render(assigns) do
    Phoenix.View.render(LotdWeb.ItemView, "form.html", assigns)
  end
end
