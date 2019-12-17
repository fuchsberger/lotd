defmodule LotdWeb.FormComponent do
  use Phoenix.LiveComponent

  alias Lotd.Museum
  alias Lotd.Museum.{Item, Mod}

  def handle_event("dismiss", _params, socket) do
    {:noreply, assign(socket, error: nil, info: nil, submitted: false)}
  end

  def handle_event("validate", %{"item" => item_params}, socket) do
    item = socket.assigns.changeset.data
    changeset = Museum.change_item(item, item_params)
    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("validate", %{"mod" => mod_params}, socket) do
    changeset = Museum.change_mod(socket.assigns.changeset.data, mod_params)
    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("create", %{"mod" => mod_params}, socket) do
    case Museum.create_mod(mod_params) do
      {:ok, mod } ->

        LotdWeb.Endpoint.broadcast("mods", "created_mod", mod)
        # send self(), {:mod_created, mod}

        {:noreply, assign(socket,
          changeset: Museum.change_mod(%Mod{}, mod_params),
          info: "#{mod.name} was created.",
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

  def render(assigns), do: Phoenix.View.render(LotdWeb.LayoutView, "form.html", assigns)
end
