defmodule LotdWeb.UserController do
  use LotdWeb, :controller

  alias Lotd.Accounts

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.html", users: users)
  end

  def update(conn, %{"id" => id} = params) do
    user = Accounts.get_user!(id)

    case Accounts.update_user(user, params) do
      {:ok, _user} ->
        redirect(conn, to: Routes.user_path(conn, :index))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Could not update user")
        |> redirect(to: Routes.user_path(conn, :index))
    end
  end
end
