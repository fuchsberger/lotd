defmodule LotdWeb.ItemController do
  use LotdWeb, :controller

  alias Lotd.Gallery
  alias Lotd.Gallery.Item

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns.current_user]
    apply(__MODULE__, action_name(conn), args)
  end

  def home(conn, _params, _current_user), do: redirect(conn, to: Routes.item_path(conn, :index))

  def index(conn, _params, _current_user) do
    items = Gallery.list_items()
    render(conn, "index.html", items: items)
  end

  def new(conn, _params, _current_user) do
    changeset = Gallery.change_item(%Item{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"item" => item_params}, _current_user) do
    case Gallery.create_item(item_params) do
      {:ok, item} ->
        conn
        |> put_flash(:info, "#{item.name} created.")
        |> redirect(to: Routes.item_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}, _current_user) do
    item = Gallery.get_item!(id)
    changeset = Gallery.change_item(item)
    render(conn, "edit.html", changeset: changeset)
  end

  def update(conn, %{"id" => id, "item" => item_params}, _current_user) do
    item =  Gallery.get_item!(id)
    case Gallery.update_item(item, item_params) do
      {:ok, item} ->
        conn
        |> put_flash(:info, "#{item.name} was edited.")
        |> redirect(to: Routes.item_path(conn, :index))
      {:error, changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, current_user) do
    item = Gallery.get_item!(id)
    {:ok, _character} = Gallery.delete_item(item)

    conn
    |> put_flash(:info, "Item deleted successfully.")
    |> redirect(to: Routes.item_path(conn, :index))
  end
end
