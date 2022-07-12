defmodule LotdWeb.ModController do
  use LotdWeb, :controller

  alias Lotd.{Accounts, Gallery}

  def index(conn, _params) do
    mods = Gallery.list_mods()
    render(conn, "index.html", mods: mods)
  end

  def toggle(conn, %{"id" => id}) do
    case Accounts.toggle_mod(conn.assigns.current_user, id) do
      {:ok, _user} ->
        redirect(conn, to: Routes.mod_path(conn, :index))

      {:error, _changeset} ->
        conn
        |> put_flash(:error, gettext "Could not toggle mod.")
        |> redirect(to: Routes.mod_path(conn, :index))
    end
  end

  def toggle_all(conn, _params) do
    case Accounts.toggle_mods(conn.assigns.current_user) do
      {:ok, _user} ->
        redirect(conn, to: Routes.mod_path(conn, :index))

      {:error, _changeset} ->
        conn
        |> put_flash(:error, gettext "Could not toggle all mods.")
        |> redirect(to: Routes.mod_path(conn, :index))
    end
  end
end
