defmodule LotdWeb.Api.FallbackController do
  use Phoenix.Controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(400)
    |> json(%{errors: changeset.errors})
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(401)
    |> json(%{error: :unauthorized})
  end

  def call(conn, {:error, :forbidden}) do
    conn
    |> put_status(403)
    |> json(%{error: :forbidden})
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(404)
    |> json(%{error: :not_found})
  end
end
