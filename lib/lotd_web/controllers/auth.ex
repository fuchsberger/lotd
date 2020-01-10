defmodule LotdWeb.Auth do

  import Plug.Conn
  import Phoenix.Controller
  alias LotdWeb.Router.Helpers, as: Routes

  def init(opts), do: opts

  def call(conn, _opts) do

    user_id = get_session(conn, :user_id)

    cond do
      user = conn.assigns[:current_user] ->
        put_current_user(conn, user)
      user = user_id && Lotd.Accounts.get_basic_user!(user_id) ->
        put_current_user(conn, user)
      true ->
        assign(conn, :current_user, nil)
    end
  end

  defp put_current_user(conn, user) do
    token = Phoenix.Token.sign(conn, "user_socket", user.id)

    conn
    |> assign(:current_user, user)
    |> assign(:user_token, token)
  end

  def login(conn, user) do
    # load user, active_character and it's items and mods
    user = Lotd.Accounts.get_basic_user!(user.id)

    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  def logout(conn) do
    configure_session(conn, drop: true)
  end

  def is_authenticated(conn, _params) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be an logged in to access that page")
      |> redirect(to: Routes.gallery_path(conn, :index))
      |> halt()
    end
  end

  def is_moderator(conn, _params) do
    if conn.assigns.current_user && conn.assigns.current_user.moderator do
      conn
    else
      conn
      |> put_flash(:error, "You must be a moderator to access that page")
      |> redirect(to: Routes.gallery_path(conn, :index))
      |> halt()
    end
  end

  def is_admin(conn, _params) do
    if conn.assigns.current_user && conn.assigns.current_user.admin do
      conn
    else
      conn
      |> put_flash(:error, "You must be an administrator to access that page")
      |> redirect(to: Routes.gallery_path(conn, :index))
      |> halt()
    end
  end
end
