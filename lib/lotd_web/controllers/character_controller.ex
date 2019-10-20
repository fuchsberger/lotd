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
end
