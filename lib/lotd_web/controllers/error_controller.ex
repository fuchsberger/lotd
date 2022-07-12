defmodule LotdWeb.ErrorController do
  use Phoenix.Controller

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(401)
    |> put_view(LotdWeb.ErrorView)
    |> render(:"401")
  end

  def call(conn, {:error, :forbidden}) do
    conn
    |> put_status(403)
    |> put_view(LotdWeb.ErrorView)
    |> render(:"403")
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(404)
    |> put_view(LotdWeb.ErrorView)
    |> render(:"404")
  end
end
