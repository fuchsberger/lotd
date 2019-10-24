defmodule LotdWeb.ModeratorChannel do
  use LotdWeb, :channel

  alias Lotd.Gallery
  alias LotdWeb.Endpoint

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
        item = Phoenix.View.render_one(item, DataView, "item.json")
        Endpoint.broadcast("public", "add-item", item)
        {:reply, :ok, socket}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:reply, {:error, %{errors: error_map(changeset)}}, socket}
    end
  end
end
