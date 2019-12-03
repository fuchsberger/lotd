defmodule LotdWeb.ItemFormComponent do
  use Phoenix.LiveComponent

  alias Lotd.Items

  def handle_event("dismiss", _params, socket) do
    {:noreply, assign(socket, error: nil, info: nil)}
  end

  def handle_event("validate", %{"item" => item_params}, socket) do
    item = socket.assigns.changeset.data
    changeset = Museum.change_item(item, item_params)
    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"item" => item_params}, socket) do
    changeset =
      socket.assigns.changeset.data
      |> Museum.change_item(item_params)

    case Museum.save_item(changeset) do
      {:ok, item } ->

        # broadcast update to view


        {:noreply, assign(socket, changeset: changeset, info: "#{item.name} was saved.", submitted: false)}
      {:error, changeset } ->
        {:noreply, assign(socket, changeset: changeset, error: "Please check your inputs.", submitted: true)}
    end
  end

  def render(assigns) do
    Phoenix.View.render(LotdWeb.ItemView, "form.html", assigns)
  end
end
