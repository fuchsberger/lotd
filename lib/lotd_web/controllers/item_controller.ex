defmodule LotdWeb.ItemController do
  use LotdWeb, :controller

  alias Lotd.{Accounts, Gallery, Skyrim, Repo}
  alias Lotd.Gallery.Item

  plug :load_displays when action in [:new, :create, :edit, :update]
  plug :load_locations when action in [:new, :create, :edit, :update]
  plug :load_mods when action in [:new, :create, :edit, :update]
  plug :load_quests when action in [:new, :create, :edit, :update]

  defp load_displays(conn, _), do: assign conn, :displays, Gallery.list_displays()
  defp load_locations(conn, _), do: assign conn, :locations, Skyrim.list_locations()
  defp load_mods(conn, _), do: assign conn, :mods, Skyrim.list_mods()
  defp load_quests(conn, _), do: assign conn, :quests, Skyrim.list_quests()

  def index(conn, _params) do
    if authenticated?(conn) do
      character = Repo.preload(character(conn), :mods)
      citems = Enum.map(character.items, fn i -> i.id end)
      cmods = Enum.map(character.mods, fn m -> m.id end)
      render conn, "index.html", items: Gallery.list_items(cmods), character_items: citems
    else
      render conn, "index.html", items: Gallery.list_items()
    end
  end

  def new(conn, _params) do
    changeset = Gallery.change_item(%Item{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"item" => item_params}) do
    case Gallery.create_item(item_params) do
      {:ok, item} ->
        conn
        |> put_flash(:info, "#{item.name} created.")
        |> redirect(to: Routes.item_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    item = Gallery.get_item!(id)
    changeset = Gallery.change_item(item)
    render(conn, "edit.html", changeset: changeset)
  end

  def update(conn, %{"id" => id, "item" => item_params}) do
    item =  Gallery.get_item!(id)
    case Gallery.update_item(item, item_params) do
      {:ok, item} ->
        conn
        |> put_flash(:info, "#{item.name} was edited.")
        |> redirect(to: Routes.item_path(conn, :index))
      {:error, changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    item = Gallery.get_item!(id)
    {:ok, _character} = Gallery.delete_item(item)

    conn
    |> put_flash(:info, "Item deleted successfully.")
    |> redirect(to: Routes.item_path(conn, :index))
  end

  def collect(conn, %{"id" => item_id}) do
    items = character(conn).items ++ [Gallery.get_item!(item_id)]
    Accounts.update_character(character(conn), :items, items)
    redirect(conn, to: Routes.item_path(conn, :index))
  end

  def borrow(conn, %{"id" => item_id}) do
    item_id = String.to_integer(item_id)
    items = Enum.reject(character(conn).items, fn i -> i.id == item_id end)
    Accounts.update_character(character(conn), :items, items)
    redirect(conn, to: Routes.item_path(conn, :index))
  end
end
