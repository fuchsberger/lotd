defmodule LotdWeb.ModController do
  use LotdWeb, :controller

  alias Lotd.Museum
  alias Lotd.Museum.Mod

  def new(conn, _params) do
    changeset = Museum.change_mod(%Mod{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"mod" => mod_params}) do
    case Museum.create_mod(mod_params) do
      {:ok, _mod} ->
        redirect(conn, to: Routes.mod_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    mod = Museum.get_mod!(id)
    changeset = Museum.change_mod(mod)
    render(conn, "edit.html", changeset: changeset)
  end

  def update(conn, %{"id" => id, "mod" => mod_params}) do
    mod = Museum.get_mod!(id)
    case Museum.update_mod(mod, mod_params) do
      {:ok, _mod} ->
        redirect(conn, to: Routes.mod_path(conn, :index))
      {:error, changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    mod = Museum.get_mod!(id)
    {:ok, _mod} = Museum.delete_mod(mod)

    conn
    |> put_flash(:info, "Mod and all associated items, locations, and quests deleted successfully.")
    |> redirect(to: Routes.mod_path(conn, :index))
  end
end
