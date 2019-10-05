defmodule LotdWeb.CharacterController do
  use LotdWeb, :controller

  alias Lotd.Accounts
  alias Lotd.Accounts.Character

  plug :load_characters when action in [:index, :update, :delete]

  defp load_characters(conn, _),
    do: assign conn, :characters, Accounts.list_user_characters(user(conn))

  def index(conn, _params), do: render(conn, "index.html")

  def new(conn, _params) do
    changeset = Accounts.change_character(%Character{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"character" => character_params}) do
    user = user(conn)
    case Accounts.create_character(user, character_params) do
      {:ok, character} ->

        #  automatically activate it
        Accounts.update_user(user, %{ active_character_id: character.id})

        conn
        |> put_flash(:info, "Character was sucessfully created and activated. Please select the mods you are going to use:")
        |> redirect(to: Routes.mod_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def update(conn, %{"id" => id}) do
    character = Enum.find(conn.assigns.characters, fn c -> c.id == String.to_integer(id) end)
    if is_nil(character) do
      conn
      |> put_flash(:info, "This character does not exist or you do not own him.")
      |> redirect(to: Routes.character_path(conn, :index))
    else
      case Accounts.update_user(user(conn),  %{ active_character_id: character.id }) do
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

  def delete(conn, %{"id" => id}) do

    # if this is the active character do not allow deleting it
    if active_character_id(conn) == String.to_integer(id) do
      conn
      |> put_flash(:info, "Nice try. You still cannot delete your active character.")
      |> redirect(to: Routes.character_path(conn, :index))
    else
      character = Enum.find(conn.assigns.characters, fn c -> c.id == String.to_integer(id) end)
      {:ok, _character} = Accounts.delete_character(character)

      conn
      |> put_flash(:info, "Character deleted successfully.")
      |> redirect(to: Routes.character_path(conn, :index))
    end
  end
end
