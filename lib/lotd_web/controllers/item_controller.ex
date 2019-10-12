defmodule LotdWeb.ItemController do
  use LotdWeb, :controller

  alias Lotd.{Gallery, Skyrim}
  alias Lotd.Gallery.Item

  plug :load_displays when action in [:index, :edit, :update]
  plug :load_locations when action in [:index, :edit, :update]
  plug :load_mods when action in [:index, :edit, :update]
  plug :load_quests when action in [:index, :edit, :update]

  defp load_displays(conn, _), do: assign conn, :displays, Gallery.list_displays()
  defp load_locations(conn, _), do: assign conn, :locations, Skyrim.list_locations()
  defp load_mods(conn, _), do: assign conn, :mods, Skyrim.list_mods()
  defp load_quests(conn, _), do: assign conn, :quests, Skyrim.list_quests()

  def index(conn, _params), do: render conn, "index.html"

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
end
