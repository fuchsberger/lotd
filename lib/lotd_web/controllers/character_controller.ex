defmodule LotdWeb.CharacterController do
  use LotdWeb, :controller

  alias Lotd.Accounts
  alias Lotd.Accounts.Character

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns.current_user]
    apply(__MODULE__, action_name(conn), args)
  end

  def index(conn, _params, current_user) do
    characters = Accounts.list_user_characters(current_user)
    render(conn, "index.html", characters: characters)
  end

  def new(conn, _params, _current_user) do
    changeset = Accounts.change_character(%Character{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"character" => character_params}, current_user) do
    case Accounts.create_character(current_user, character_params) do
      {:ok, character} ->

        # if it is first character, automatically activate it
        character_count = current_user |> Accounts.list_user_characters() |> Enum.count()
        if character_count == 1,
          do: Accounts.update_user(current_user, %{ active_character_id: character.id})

        conn
        |> put_flash(:info, "Character was sucessfully created. Please select the mods you are going to use:")
        |> redirect(to: Routes.mod_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def update(conn, %{"id" => id}, current_user) do
    character = Enum.find(current_user.characters, fn c -> c.id == String.to_integer(id) end)
    if is_nil(character) do
      conn
      |> put_flash(:info, "This character does not exist or you do not own him.")
      |> redirect(to: Routes.character_path(conn, :index))
    else
      case Accounts.update_user(current_user,  %{ active_character_id: character.id }) do
        {:ok, _user} ->
          conn
          |> put_flash(:info, "#{character.name} is hunting relics...")
          |> redirect(to: Routes.character_path(conn, :index))
        {:error, _reason} ->
          conn
          |> put_flash(:info, "Database Error. Character could not be activated.")
          |> redirect(to: Routes.character_path(conn, :index))
      end
    end
  end

  def delete(conn, %{"id" => id}, current_user) do

    # if this is the active character do not allow deleting it
    if active_character_id(conn) == String.to_integer(id) do
      conn
      |> put_flash(:info, "Nice try. You still cannot delete your active character.")
      |> redirect(to: Routes.character_path(conn, :index))
    else
      character = Enum.find(current_user.characters, fn c -> c.id == String.to_integer(id) end)
      {:ok, _character} = Accounts.delete_character(character)

      conn
      |> put_flash(:info, "Character deleted successfully.")
      |> redirect(to: Routes.character_path(conn, :index))
    end
  end
end
