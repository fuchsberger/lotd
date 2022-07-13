defmodule LotdWeb.ModController do
  use LotdWeb, :controller

  alias Lotd.{Accounts, Gallery}
  alias Lotd.Gallery.Mod

  action_fallback LotdWeb.ErrorController

  def index(conn, _params) do
    mods = Gallery.list_mods()
    render(conn, "index.html", action: nil, mods: mods)
  end

  def new(conn, _params) do
    mods = Gallery.list_mods()

    changeset = Gallery.change_mod(%Mod{})
    render(conn, "index.html", action: :create, changeset: changeset, mods: mods)
  end

  def create(conn, %{"mod" => mod_params}) do
    mods = Gallery.list_mods()

    case Gallery.create_mod(mod_params) do
      {:ok, _mod} ->
        conn
        |> put_flash(:info, "Mod created successfully.")
        |> redirect(to: Routes.mod_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "index.html", action: :create, changeset: changeset, mods: mods)
    end
  end

  def edit(conn, %{"id" => id}) do
    with mods <- Gallery.list_mods(),
        %Mod{} = mod <- Gallery.get_mod!(id) do
      changeset = Gallery.change_mod(mod)
      render(conn, "index.html", action: :update, changeset: changeset, mod: mod, mods: mods)
    end
  end

  def update(conn, %{"id" => id, "mod" => mod_params}) do
    with mods <- Gallery.list_mods(),
        %Mod{} = mod <- Gallery.get_mod!(id) do
      case Gallery.update_mod(mod, mod_params) do
        {:ok, _mod} ->
          conn
          |> put_flash(:info, "Mod updated successfully.")
          |> redirect(to: Routes.mod_path(conn, :index))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "index.html", action: :update, changeset: changeset, mod: mod, mods: mods)
      end
    end
  end

  def remove(conn, %{"id" => id}) do
    with mods <- Gallery.list_mods(),
        %Mod{} = mod <- Gallery.get_mod!(id) do
      render(conn, "index.html", action: :delete, mod: mod, mods: mods)
    end
  end

  def delete(conn, %{"id" => id}) do
    with %Mod{} = mod <- Gallery.get_mod!(id),
        {:ok, _mod} = Gallery.delete_mod(mod)
    do
      conn
      |> put_flash(:info, "Mod deleted successfully.")
      |> redirect(to: Routes.mod_path(conn, :index))
    end
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
