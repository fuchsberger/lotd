defmodule LotdWeb.ModController do
  use LotdWeb, :controller

  alias Lotd.{Repo, Accounts, Skyrim}
  alias Lotd.Skyrim.Mod

  plug :mod_ids when action in [:activate, :deactivate, :index]

  def mod_ids(conn, _) do
    character = Repo.preload(character(conn), :mods)
    assign conn, :current_user, Map.put(user(conn), :active_character, character)
  end

  def index(conn, _params) do

    character_mods = Enum.map(character(conn).mods, fn m -> m.id end)

    mods = Skyrim.list_mods()

    mods =
      if authenticated?(conn) do
        Enum.map(mods, fn m ->
          common_ids = m.items -- character(conn).items
          common_ids = m.items -- common_ids
          m
          |> Map.put(:found_items, Enum.count(common_ids))
          |> Map.put(:items, Enum.count(m.items))
        end)
      else
        mods
      end

    render conn, "index.html", mods: mods, character_mods: character_mods
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
