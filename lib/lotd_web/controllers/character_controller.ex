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
        if character_count == 1, do: Accounts.activate_character(current_user, character)

        conn
        |> put_flash(:info, "Character was sucessfully created and activated. Good hunting!")
        |> redirect(to: Routes.character_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def update(conn, %{"id" => id}, current_user) do
    character =  Accounts.get_user_character!(current_user, id)
    case Accounts.activate_character(current_user, character) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "#{character.name} is hunting relics...")
        |> redirect(to: Routes.character_path(conn, :index))
      {:error, _reason} ->
        conn
        |> put_flash(:info, "Error: TODO: improve this...")
        |> redirect(to: Routes.character_path(conn, :index))
    end
  end

  def delete(conn, %{"id" => id}, current_user) do

    # if this is the active character, remove it from user as well
    if current_user.active_character_id == String.to_integer(id) do
      Accounts.update_user(current_user, %{ active_character_id: nil })
    end

    character = Accounts.get_user_character!(current_user, id)
    {:ok, _character} = Accounts.delete_character(character)

    conn
    |> put_flash(:info, "Character deleted successfully.")
    |> redirect(to: Routes.character_path(conn, :index))
  end
end
