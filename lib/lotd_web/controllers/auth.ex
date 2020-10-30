defmodule LotdWeb.Auth do

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)

    cond do
      user = conn.assigns[:current_user] ->
        put_current_user(conn, user)
      user = user_id && Lotd.Accounts.get_user(user_id) ->
        put_current_user(conn, user)
      true ->
        assign(conn, :current_user, nil)
    end
  end

  defp put_current_user(conn, user) do
    assign(conn, :user_token, Phoenix.Token.sign(conn, "user_socket", user.id))
  end

  def login(conn, user) do
    case user do
      nil ->
        conn
      user ->
        conn
        |> put_session(:user_id, user.id)
        |> configure_session(renew: true)
    end
  end

  def logout(conn), do: configure_session(conn, drop: true)
end
