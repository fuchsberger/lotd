defmodule LotdWeb.Api.CharacterController do
  use LotdWeb, :controller

  alias Lotd.Accounts
  alias Lotd.Accounts.{Character, User}
  alias LotdWeb.Api.CharacterView

  action_fallback LotdWeb.Api.FallbackController

  def index(conn, _params) do
    active_id = conn.assigns.current_user.active_character_id
    characters = Accounts.list_user_characters(conn.assigns.current_user)
    render(conn, "characters.json", characters: characters, active_id: active_id)
  end

  def create(conn, %{"character" => character_params}) do
    case Accounts.create_character(conn.assigns.current_user, character_params) do
      {:ok, character} ->
        character = Accounts.preload_items(character)
        json(conn, %{success: true, character: CharacterView.render("character.json",
        character: character, active_id: conn.assigns.current_user.active_character_id )})

      {:error, %Ecto.Changeset{} = _changeset} ->
        json(conn, %{success: false})
    end
  end

  def update(conn, %{"id" => id, "character" => character_params}) do
    with %Character{} = character <- Accounts.get_character!(id),
        :ok <- owned?(conn.assigns.current_user, character) do
      case Accounts.update_character(character, character_params) do
        {:ok, character} ->
          character = Accounts.preload_items(character)
          json(conn, %{success: true, character: CharacterView.render("character.json",
          character: character, active_id: conn.assigns.current_user.active_character_id )})

        {:error, %Ecto.Changeset{} = _changeset} ->
          json(conn, %{success: false})
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    with %Character{} = character <- Accounts.get_character!(id),
        :ok <- owned?(conn.assigns.current_user, character),
        {:ok, character} = Accounts.delete_character(character)
    do
      json(conn, %{deleted_id: character.id})
    end
  end

  def activate(conn, %{"id" => id}) do
    with %Character{} = character <- Accounts.get_character!(id),
    :ok <- owned?(conn.assigns.current_user, character) do
      case Accounts.update_user(conn.assigns.current_user, %{active_character_id: id}) do
        {:ok, _user} ->
          json(conn, %{success: true, old_active_id: conn.assigns.current_user.active_character_id})

        {:error, %Ecto.Changeset{} = _changeset} ->
          json(conn, %{success: false})
      end
    end
  end

  defp owned?(%User{} = user, %Character{} = character) do
    if character.user_id == user.id, do: :ok, else: {:error, :forbidden}
  end
end
