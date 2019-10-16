defmodule LotdWeb.ModeratorChannel do
  use LotdWeb, :channel

  alias Lotd.Gallery
  alias LotdWeb.{Endpoint, ItemView}

  def join("moderator", _params, socket) do
    if moderator?(socket) do
      {:ok, socket}
    else
      {:error, %{ reason: "You must be authenticated to join this channel." }}
    end
  end

  def handle_in("add-item", item_params, socket) do
    case Gallery.create_item(item_params) do
      {:ok, item} ->
        item = Phoenix.View.render_one(item, ItemView, "item.json")
        Endpoint.broadcast("public", "add-item", %{ item: item})
        {:reply, :ok, socket}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:reply, {:error, %{errors: error_map(changeset)}}, socket}
    end
  end

  def handle_in("delete", %{ "id" => id}, socket) do
    if admin?(socket) do
      {:ok, item} = Gallery.get_item!(id) |> Gallery.delete_item()
      Endpoint.broadcast("public", "delete-item", %{ id: item.id})
      {:reply, :ok, socket}
    else
      {:reply, :error, socket}
    end
  end
end
