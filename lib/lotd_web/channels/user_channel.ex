defmodule LotdWeb.UserChannel do
  use LotdWeb, :channel

  alias Lotd.{Accounts, Gallery, Skyrim}
  alias LotdWeb.{CharacterView}

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

  def handle_in("add-character", params, socket) do
    case Accounts.create_character(socket.assigns.user, params) do
      {:ok, character} ->
        character = character
          |> Map.put(:items, [])
          |> Map.put(:mods, [])
          |> Phoenix.View.render_one(CharacterView, "character.json")
        broadcast(socket, "add-character", character)
        {:reply, :ok, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:reply, {:error, %{errors: error_map(changeset)}}, socket}
    end
  end

  def handle_in("activate_mod", %{ "id" => id}, socket) do
    Accounts.get_active_character(socket.assigns.user)
    |> Accounts.update_character_add_mod(Skyrim.get_mod!(id))
    {:reply, :ok, socket}
  end

  def handle_in("deactivate_mod", %{ "id" => id}, socket) do
    Accounts.get_active_character(socket.assigns.user)
    |> Accounts.update_character_remove_mod(id)
    {:reply, :ok, socket}
  end

  def handle_in("logout", _params, socket) do
    LotdWeb.Endpoint.broadcast("user_socket:" <> socket.assigns.user.id, "disconnect", %{})
  end
end
