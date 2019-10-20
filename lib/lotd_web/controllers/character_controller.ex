defmodule LotdWeb.CharacterController do
  use LotdWeb, :controller

  alias Lotd.Accounts

  plug :load_characters when action in [:edit, :update]

  defp load_characters(conn, _),
    do: assign conn, :characters, Accounts.list_user_characters(user(conn))

  def edit(conn, %{"id" => id}) do
    character = Enum.find(conn.assigns.characters, fn c -> c.id == String.to_integer(id) end)
    changeset = Accounts.change_character(character)
    render(conn, "edit.html", changeset: changeset)
  end

  def update(conn, %{"id" => id, "character" => character_params}) do
    character = Enum.find(conn.assigns.characters, fn c -> c.id == String.to_integer(id) end)
    Accounts.update_character(character, character_params)
    redirect(conn, to: Routes.character_path(conn, :index))
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
