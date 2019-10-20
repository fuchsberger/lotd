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

  def handle_in("update-character", %{"id" => id, "name" => name}, socket) do
    character = Accounts.get_user_character!(socket.assigns.user, id)
    case Accounts.update_character(character, %{ name: name }) do
      {:ok, character} ->
        broadcast(socket, "update-character", %{ id: character.id, name: character.name })
        {:reply, :ok, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:reply, {:error, %{errors: error_map(changeset)}}, socket}
    end
  end

  def handle_in("delete-character", %{"id" => id}, socket) do
    # if this is the active character do not allow deleting it
    if socket.assigns.user.active_character_id == String.to_integer(id) do
      {:reply, :error, socket}
    else
      user_characters = Accounts.list_user_characters(socket.assigns.user)
      character = Enum.find(user_characters, fn c -> c.id == String.to_integer(id) end)
      case Accounts.delete_character(character) do
        {:ok, character} ->
          broadcast(socket, "delete-character", %{ id: character.id })
          {:reply, :ok, socket}
        {:error, changeset} ->
          {:reply, {:error, %{errors: error_map(changeset)}}, socket}
      end
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
