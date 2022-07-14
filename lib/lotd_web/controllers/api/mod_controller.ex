defmodule LotdWeb.Api.ModController do
  use LotdWeb, :controller

  alias Lotd.Accounts
  alias Lotd.Gallery
  alias Lotd.Gallery.Mod
  alias LotdWeb.Api.ModView

  def index(conn, _params) do
    mods = Gallery.list_mods()
    user_mod_ids = if conn.assigns.current_user, do: conn.assigns.current_user.mods, else: []

    render(conn, "mods.json", mods: mods, user_mod_ids: user_mod_ids)
  end

  def create(conn, %{"mod" => mod_params}) do
    case Gallery.create_mod(mod_params) do
      {:ok, mod} ->
        mod = Gallery.preload_mod(mod)
        json(conn, %{success: true, mod: ModView.render("mod.json",
        mod: mod, user_mod_ids: conn.assigns.current_user.mods )})

      {:error, %Ecto.Changeset{} = _changeset} ->
        json(conn, %{success: false})
    end
  end

  def update(conn, %{"id" => id, "mod" => mod_params}) do
    with %Mod{} = mod <- Gallery.get_mod!(id) do
      case Gallery.update_mod(mod, mod_params) do
        {:ok, mod} ->
          mod = Gallery.preload_mod(mod)
          json(conn, %{success: true, mod: ModView.render("mod.json",
          mod: mod, user_mod_ids: conn.assigns.current_user.mods )})

        {:error, %Ecto.Changeset{} = _changeset} ->
          json(conn, %{success: false})
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    with %Mod{} = mod <- Gallery.get_mod!(id),
        {:ok, mod} = Gallery.delete_mod(mod) do
      json(conn, %{deleted_id: mod.id})
    end
  end

  def toggle(conn, %{"id" => id}) do
    case Accounts.toggle_mod(conn.assigns.current_user, id) do
      {:ok, _user} ->
        json(conn, %{success: true})

      {:error, _changeset} ->
        json(conn, %{success: false})
    end
  end

  def toggle_all(conn, _params) do
    case Accounts.toggle_mods(conn.assigns.current_user) do
      {:ok, _user} ->
        json(conn, %{success: true, status: true})

      {:error, _changeset} ->
        json(conn, %{success: false})
    end
  end
end
