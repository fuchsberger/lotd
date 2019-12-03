defmodule LotdWeb.DisplayController do
  use LotdWeb, :controller

  alias Lotd.Museum
  alias Lotd.Museum.Display

  def new(conn, _params) do
    changeset = Museum.change_display(%Display{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"display" => display_params}) do
    case Museum.create_display(display_params) do
      {:ok, _display} ->
        redirect(conn, to: Routes.display_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    display = Museum.get_display!(id)
    changeset = Museum.change_display(display)
    render(conn, "edit.html", changeset: changeset)
  end

  def update(conn, %{"id" => id, "display" => display_params}) do
    display = Museum.get_display!(id)
    case Museum.update_display(display, display_params) do
      {:ok, _display} ->
        redirect(conn, to: Routes.display_path(conn, :index))
      {:error, changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    display = Museum.get_display!(id)
    {:ok, _display} = Museum.delete_display(display)

    conn
    |> put_flash(:info, "Display with all contained items deleted successfully.")
    |> redirect(to: Routes.display_path(conn, :index))
  end
end
