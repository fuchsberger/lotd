defmodule LotdWeb.CharacterController do
  use LotdWeb, :controller

  alias Lotd.Accounts
  alias Lotd.Accounts.Character

  action_fallback LotdWeb.ErrorController

  def index(conn, _params) do
    render conn, "index.html", action: nil, changeset: Accounts.change_character(%Character{})
  end

  def toggle(conn, %{"item_id" => id}) do
    collected = Accounts.toggle_item!(conn.assigns.current_user.active_character, id)
    Accounts.refresh_character!(conn.assigns.current_user.active_character)

    conn
    |> put_status(200)
    |> json(%{collected: collected})
  end
end
