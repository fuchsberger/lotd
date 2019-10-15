defmodule LotdWeb.UserChannel do
  use LotdWeb, :channel

  alias Lotd.{Accounts, Gallery}
  alias LotdWeb.{CharacterView, ItemView}

  def join("user:" <> user_id, _params, socket) do
    if authenticated?(socket) && socket.assigns.user.id == String.to_integer(user_id) do
      characters = Accounts.list_user_characters(socket.assigns.user)
      {:ok, %{
        character_id: socket.assigns.user.active_character_id,
        characters: Phoenix.View.render_many(characters, CharacterView, "character.json" ),
      }, socket}
    else
      {:error, %{ reason: "You must be authenticated to join this channel." }}
    end
  end

  def handle_in("add", item_params, socket) do
    if moderator?(socket) do
      case Gallery.create_item(item_params) do
        {:ok, item} ->
          item = Phoenix.View.render_one(item, ItemView, "item.json")
          broadcast(socket, "add", %{ item: item})
          {:reply, :ok, socket}
        {:error, %Ecto.Changeset{} = changeset} ->
          {:reply, {:error, %{errors: error_map(changeset)}}, socket}
      end
    else
      {:reply, :error, socket}
    end
  end

  def handle_in("delete", %{ "id" => id}, socket) do
    if admin?(socket) do
      {:ok, item} = Gallery.get_item!(id) |> Gallery.delete_item()
      broadcast(socket, "delete", %{ id: item.id})
      {:reply, :ok, socket}
    else
      {:reply, :error, socket}
    end
  end

  def handle_in("collect_item", %{ "id" => id}, socket) do
    Accounts.get_active_character(socket.assigns.user)
    |> Accounts.update_character_add_item(Gallery.get_item!(id))
    {:reply, :ok, socket}
  end

  def handle_in("remove_item", %{ "id" => id}, socket) do
    Accounts.get_active_character(socket.assigns.user)
    |> Accounts.update_character_remove_item(id)
    {:reply, :ok, socket}
  end

  def handle_in("activate_character", %{ "id" => id}, socket) do
    case Accounts.get_user_character!(socket.assigns.user, id) do
      nil ->
        {:reply, { :error, %{
          reason: "This character does not exist or does not belong to you"}
        }, socket}
      character ->
        case Accounts.update_user(socket.assigns.user, %{ active_character_id: character.id }) do
          {:ok, _user} ->
            {:reply, {:ok, %{ info: "#{character.name} is now hunting relics."}}, socket}
          {:error, reason} ->
            {:reply, { :error, %{ reason: "Database Error. #{reason}"}}, socket}
        end
    end
  end

  def handle_in("logout", _params, socket) do
    LotdWeb.Endpoint.broadcast("user_socket:" <> socket.assigns.user.id, "disconnect", %{})
  end
end
