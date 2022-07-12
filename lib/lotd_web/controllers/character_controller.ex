defmodule LotdWeb.CharacterController do
  use LotdWeb, :controller

  alias Lotd.Accounts
  alias Lotd.Accounts.Character

  def index(conn, _params) do
    characters = Accounts.list_user_characters(conn.assigns.current_user)
    render(conn, "index.html", characters: characters)
  end

  def new(conn, _params) do
    changeset = Accounts.change_character(%Character{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"character" => character_params}) do
    characters = Accounts.list_user_characters(conn.assigns.current_user)
    if Enum.count(characters) < 10 do
      case Accounts.create_character(conn.assigns.current_user, character_params) do
        {:ok, _character} ->
          conn
          |> put_flash(:info, "Character created successfully.")
          |> redirect(to: Routes.character_path(conn, :index))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "new.html", changeset: changeset)
      end
    else
      conn
      |> put_flash(:info, "You cannot create more than 10 characters.")
      |> redirect(to: Routes.character_path(conn, :index))
    end
  end

  def edit(conn, %{"id" => id}) do
    character = Accounts.get_character!(id)
    changeset = Accounts.change_character(character)
    render(conn, "edit.html", character: character, changeset: changeset)
  end

  def update(conn, %{"id" => id, "character" => character_params}) do
    character = Accounts.get_character!(id)

    case Accounts.update_character(character, character_params) do
      {:ok, _character} ->
        conn
        |> put_flash(:info, "Character updated successfully.")
        |> redirect(to: Routes.character_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", character: character, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    character = Accounts.get_character!(id)
    {:ok, _character} = Accounts.delete_character(character)

    conn
    |> put_flash(:info, "Character deleted successfully.")
    |> redirect(to: Routes.character_path(conn, :index))
  end

  def activate(conn, %{"id" => id}) do
    character = Accounts.get_character!(id)
    if character.user_id == conn.assigns.current_user.id do
      case Accounts.update_user(conn.assigns.current_user, %{active_character_id: id}) do
        {:ok, _character} ->
          conn
          |> put_flash(:info, "Character updated successfully.")
          |> redirect(to: Routes.character_path(conn, :index))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html", character: character, changeset: changeset)
      end
    else
      conn
      |> put_flash(:info, "You cannot activate another players character, hacker!")
      |> redirect(to: Routes.character_path(conn, :index))
    end
  end
end
