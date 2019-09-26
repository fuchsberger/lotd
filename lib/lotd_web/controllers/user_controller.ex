defmodule LotdWeb.UserController do
  use LotdWeb, :controller

  alias Lotd.Accounts

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.html", users: users)
  end
end
