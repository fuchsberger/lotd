defmodule LotdWeb.ItemController do
  use LotdWeb, :controller

  alias Lotd.{Accounts, Gallery}
  alias Lotd.Gallery.Item

  plug :load_displays when action in [:new, :create, :edit, :update]

  defp load_displays(conn, _), do: assign conn, :displays, Gallery.list_alphabetical_displays()

  def index(conn, _params) do
    active_character_id = active_character_id(conn)
    items = Gallery.list_items()

    character_item_ids = if active_character_id do
      active_character_id
      |> Accounts.get_character!()
      |> Accounts.character_item_ids()
    else
      []
    end
    render(conn, "index.html", items: items, character_item_ids: character_item_ids)
  end

  def new(conn, _params) do
    changeset = Gallery.change_item(%Item{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"item" => item_params}) do
    case Gallery.create_item(item_params) do
      {:ok, item} ->
        conn
        |> put_flash(:info, "#{item.name} created.")
        |> redirect(to: Routes.item_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    item = Gallery.get_item!(id)
    changeset = Gallery.change_item(item)
    render(conn, "edit.html", changeset: changeset)
  end

  def update(conn, %{"id" => id, "item" => item_params}) do
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

  def delete(conn, %{"id" => id}) do
    item = Gallery.get_item!(id)
    {:ok, _character} = Gallery.delete_item(item)

    conn
    |> put_flash(:info, "Item deleted successfully.")
    |> redirect(to: Routes.item_path(conn, :index))
  end

  def collect(conn, %{"id" => item_id}) do
    character = conn |> active_character_id() |> Accounts.get_character!()
    Gallery.collect_item(character, item_id)
    redirect(conn, to: Routes.item_path(conn, :index))
  end

  def borrow(conn, %{"id" => item_id}) do
    character = conn |> active_character_id() |> Accounts.get_character!()
    Gallery.borrow_item(character, item_id)
    redirect(conn, to: Routes.item_path(conn, :index))
  end
end
