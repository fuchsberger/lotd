defmodule LotdWeb.ModController do
  use LotdWeb, :controller

  alias Lotd.Skyrim
  alias Lotd.Skyrim.Mod

  def index(conn, _params) do
    character_item_ids = character_item_ids(conn)
    mods = Skyrim.list_alphabetical_mods()
    |> Enum.map(fn l ->
      mod_item_ids = Enum.map(l.items, fn i -> i.id end)
      common_ids = mod_item_ids -- character_item_ids
      common_ids = mod_item_ids -- common_ids
      Map.put(l, :character_item_count, Enum.count(common_ids))
    end)

    render(conn, "index.html", mods: mods, character_mod_ids: character_mod_ids(conn))
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
    Skyrim.activate_mod(conn.assigns.current_user.active_character, mod_id)
    redirect(conn, to: Routes.mod_path(conn, :index))
  end

  def deactivate(conn, %{"id" => mod_id}) do
    Skyrim.deactivate_mod(conn.assigns.current_user.active_character, mod_id)
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
