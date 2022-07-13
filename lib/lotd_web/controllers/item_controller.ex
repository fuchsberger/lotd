defmodule LotdWeb.ItemController do
  use LotdWeb, :controller

  action_fallback LotdWeb.ErrorController

  def index(conn, _params), do: render(conn, "index.html")

  # def new(conn, _params) do
  #   characters = Accounts.list_user_characters(conn.assigns.current_user)

  #   if Enum.count(characters) < 10 do
  #     changeset = Accounts.change_character(%Character{})
  #     render(conn, "index.html", action: :create, changeset: changeset, characters: characters)
  #   else
  #     conn
  #     |> put_flash(:error, gettext("You cannot create more than 10 characters."))
  #     |> redirect(to: Routes.character_path(conn, :index))
  #   end
  # end
end
