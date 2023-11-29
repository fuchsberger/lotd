defmodule LotdWeb.Api.ItemController do
  use LotdWeb, :controller

  alias Lotd.Gallery
  alias Lotd.Gallery.Item
  alias LotdWeb.ItemJSON

  def index(conn, _params) do
    render(conn, "items.json", items: Gallery.list_items())
  end

  def create(conn, %{"item" => item_params}) do
    case Gallery.create_item(item_params) do
      {:ok, item} ->
        item = Gallery.preload_item(item)
        json(conn, %{success: true, item: ItemJSON.show(%{item: item})})

      {:error, %Ecto.Changeset{} = _changeset} ->
        json(conn, %{success: false})
    end
  end

  def update(conn, %{"id" => id, "item" => item_params}) do
    with %Item{} = item <- Gallery.get_item!(id) do
      case Gallery.update_item(item, item_params) do
        {:ok, item} ->
          item = Gallery.preload_item(item)
          json(conn, %{success: true, item: ItemJSON.show(%{item: item})})

        {:error, %Ecto.Changeset{} = _changeset} ->
          json(conn, %{success: false})
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    with %Item{} = item <- Gallery.get_item!(id),
        {:ok, item} = Gallery.delete_item(item) do
      json(conn, %{deleted_id: item.id})
    end
  end
end
