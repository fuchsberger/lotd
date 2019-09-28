defmodule LotdWeb.UserController do
  use LotdWeb, :controller

  alias Lotd.Accounts

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.html", users: users)
  end

  def update(conn, %{"id" => id} = params) do
    Accounts.get_user(id)
    |> Accounts.update_user(params)

    redirect(conn, to: Routes.user_path(conn, :index))
  end
end
