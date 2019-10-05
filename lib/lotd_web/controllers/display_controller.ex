defmodule LotdWeb.DisplayController do
  use LotdWeb, :controller

  alias Lotd.Gallery
  alias Lotd.Gallery.Display

  def index(conn, _params) do
    displays = Gallery.list_alphabetical_displays()
    displays =
      if authenticated?(conn) do
        Enum.map(displays, fn d ->
          display_item_ids = Enum.map(d.items, fn i -> i.id end)
          common_ids = display_item_ids -- character_item_ids(conn)
          common_ids = display_item_ids -- common_ids
          Map.put(d, :character_item_count, Enum.count(common_ids))
        end)
      else
        displays
      end
    render(conn, "index.html", displays: displays)
  end

  def new(conn, _params) do
    changeset = Gallery.change_display(%Display{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"display" => display_params}) do
    case Gallery.create_display(display_params) do
      {:ok, _display} ->
        redirect(conn, to: Routes.display_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    display = Gallery.get_display!(id)
    changeset = Gallery.change_display(display)
    render(conn, "edit.html", changeset: changeset)
  end

  def update(conn, %{"id" => id, "display" => display_params}) do
    display = Gallery.get_display!(id)
    case Gallery.update_display(display, display_params) do
      {:ok, _display} ->
        redirect(conn, to: Routes.display_path(conn, :index))
      {:error, changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    display = Gallery.get_display!(id)
    {:ok, _display} = Gallery.delete_display(display)

    conn
    |> put_flash(:info, "Display with all contained items deleted successfully.")
    |> redirect(to: Routes.display_path(conn, :index))
  end
end
