defmodule LotdWeb.AdminChannel do
  use LotdWeb, :channel

  alias Lotd.{Accounts, Gallery}
  alias LotdWeb.Endpoint

  def join("admin", _params, socket) do
    if admin?(socket) do
      users = Accounts.list_users()
      {:ok, %{ users: Phoenix.View.render_many(users, DataView, "user.json" ) }, socket}
    else
      {:error, %{ reason: "You must be an administrator to join this channel." }}
    end
  end

  def handle_in("update-user", %{"id" => id, "params" => params}, socket) do
    case Accounts.update_user(Accounts.get_user!(id), params) do
      {:ok, user} ->
        broadcast(socket, "update-user", Phoenix.View.render_one(user, DataView, "user.json" ))
        {:reply, :ok, socket}
      {:error, _changeset} ->
        {:reply, :error, socket}
    end
  end

  def handle_in("delete-item", %{ "id" => id}, socket) do
    if admin?(socket) do
      {:ok, item} = Gallery.get_item!(id) |> Gallery.delete_item()
      Endpoint.broadcast("public", "delete-item", Phoenix.View.render_one(item, DataView, "item.json" ))
      {:reply, :ok, socket}
    else
      {:reply, :error, socket}
    end
  end
end
