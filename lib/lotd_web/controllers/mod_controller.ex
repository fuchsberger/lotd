defmodule LotdWeb.ModController do
  use LotdWeb, :controller

  alias Lotd.{Accounts, Skyrim}
  alias Lotd.Skyrim.Mod

  def index(conn, _params) do
    if authenticated?(conn) do
      character_mod_ids = Enum.map(character(conn).mods, fn m -> m.id end)
      character_item_ids = Enum.map(character(conn).items, fn i -> i.id end)

      mods = Skyrim.list_mods()
      |> Enum.map(fn m ->
        common_ids = m.items -- character_item_ids
        common_ids = m.items -- common_ids
        Map.put(m, :found_items, Enum.count(common_ids))
      end)

      render conn, "index.html", mods: mods, character_mod_ids: character_mod_ids
    else
      render conn, "index.html", mods: Skyrim.list_mods()
    end
  end

  def new(conn, _params) do
    changeset = Skyrim.change_mod(%Mod{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"mod" => mod_params}) do
    case Skyrim.create_mod(mod_params) do
      {:ok, _mod} ->
        redirect(conn, to: Routes.mod_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    mod = Skyrim.get_mod!(id)
    changeset = Skyrim.change_mod(mod)
    render(conn, "edit.html", changeset: changeset)
  end

  def update(conn, %{"id" => id, "mod" => mod_params}) do
    mod = Skyrim.get_mod!(id)
    case Skyrim.update_mod(mod, mod_params) do
      {:ok, _mod} ->
        redirect(conn, to: Routes.mod_path(conn, :index))
      {:error, changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  def activate(conn, %{"id" => mod_id}) do
    mods = character(conn).mods ++ [Skyrim.get_mod!(mod_id)]
    Accounts.update_character(character(conn), :mods, mods)
    redirect(conn, to: Routes.mod_path(conn, :index))
  end

  def deactivate(conn, %{"id" => mod_id}) do
    mod_id = String.to_integer(mod_id)
    mods = Enum.reject(character(conn).mods, fn m -> m.id == mod_id end)
    Accounts.update_character(character(conn), :mods, mods)
    redirect(conn, to: Routes.mod_path(conn, :index))
  end

  def delete(conn, %{"id" => id}) do
    mod = Skyrim.get_mod!(id)
    {:ok, _mod} = Skyrim.delete_mod(mod)

    conn
    |> put_flash(:info, "Mod and all associated items, locations, and quests deleted successfully.")
    |> redirect(to: Routes.mod_path(conn, :index))
  end
end
