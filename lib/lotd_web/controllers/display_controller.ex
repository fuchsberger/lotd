defmodule LotdWeb.DisplayController do
  use LotdWeb, :controller

  alias Lotd.Gallery
  alias Lotd.Gallery.Display

  def index(conn, _params) do
    displays = Gallery.list_displays()
    render(conn, "index.html", displays: displays)
  end

  def new(conn, _params) do
    changeset = Gallery.change_display(%Display{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"display" => display_params}) do
    case Gallery.create_display(display_params) do
      {:ok, display} ->
        conn
        |> put_flash(:info, "Display created successfully.")
        |> redirect(to: Routes.display_path(conn, :show, display))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    display = Gallery.get_display!(id)
    render(conn, "show.html", display: display)
  end

  def edit(conn, %{"id" => id}) do
    display = Gallery.get_display!(id)
    changeset = Gallery.change_display(display)
    render(conn, "edit.html", display: display, changeset: changeset)
  end

  def update(conn, %{"id" => id, "display" => display_params}) do
    display = Gallery.get_display!(id)

    case Gallery.update_display(display, display_params) do
      {:ok, display} ->
        conn
        |> put_flash(:info, "Display updated successfully.")
        |> redirect(to: Routes.display_path(conn, :show, display))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", display: display, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    display = Gallery.get_display!(id)
    {:ok, _display} = Gallery.delete_display(display)

    conn
    |> put_flash(:info, "Display deleted successfully.")
    |> redirect(to: Routes.display_path(conn, :index))
  end
end
