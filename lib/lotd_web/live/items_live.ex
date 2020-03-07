defmodule LotdWeb.ItemsLive do

  use Phoenix.LiveView, container: {:div, class: "container"}

  import LotdWeb.LiveHelpers
  alias Lotd.{Accounts, Gallery}
  alias Lotd.Gallery.Item

  def render(assigns), do: LotdWeb.ManageView.render("items.html", assigns)

  def mount(_params, %{"user_id" => user_id }, socket) do
    changeset = Gallery.change_item(%Item{})
    user = Accounts.get_user!(user_id)

    {:ok, assign(socket,
      admin: user.admin,
      changeset: changeset,
      items: Gallery.list_items(Ecto.Changeset.get_change(changeset, :name), nil),
      display_options: Gallery.list_display_options(),
      location_options: Gallery.list_location_options(),
      mod_options: Gallery.list_mod_options()
    )}
  end

  def handle_event("validate", %{"item" => params}, socket) do
    changeset = Item.changeset(socket.assigns.changeset.data, params)
    {:noreply, assign(socket,
      changeset: changeset,
      items: Gallery.list_items(Ecto.Changeset.get_change(changeset, :name), nil),
      location_options: Gallery.list_location_options()
    )}
  end

  def handle_event("save", %{"item" => _params}, socket) do
    case Lotd.Repo.insert_or_update(socket.assigns.changeset) do
      {:ok, item } ->
        item = Lotd.Repo.preload(item, [:display, :location, :mod], force: true)
        {:noreply, assign(socket,
          changeset: Gallery.change_item(%Item{}),
          items: update_collection(socket.assigns.items, item)
        )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("edit", %{"id" => id}, socket) do
    id = String.to_integer(id)
    if socket.assigns.changeset.data.id == id do
      {:noreply, assign(socket, changeset: Gallery.change_item(%Item{}))}
    else
      item = Enum.find(socket.assigns.items, & &1.id == id)
      {:noreply, assign(socket, changeset: Gallery.change_item(item))}
    end
  end

  def handle_event("delete", _params, socket) do
    item = Enum.find(socket.assigns.items, & &1.id == socket.assigns.changeset.data.id)
    case Gallery.delete_item(item) do
      {:ok, item} ->
        {:noreply, assign(socket,
          changeset: Gallery.change_item(%Item{}),
          items: Enum.reject(socket.assigns.items, & &1.id == item.id)
        )}

      {:error, _reason} ->
        {:noreply, socket}
    end

  end
end
