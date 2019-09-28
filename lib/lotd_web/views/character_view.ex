defmodule LotdWeb.CharacterView do
  use LotdWeb, :view

  alias Lotd.Accounts.Character

  def character_actions(conn, %Character{} = c) do
    [btn_activate(conn, c), btn_delete(conn, c)]
  end

  defp btn_activate(conn, character) do
    u = conn.assigns.current_user

    active = if u.active_character_id == character.id,
      do: "is-primary", else: "has-text-dark"
    link icon("user-times", class: "#{active}"),
      to: Routes.character_path(conn, :update, character.id),
      method: "put",
      title: "Activate"
  end

  defp btn_delete(conn, character) do
    link icon("user-times", class: "has-text-dark"),
      to: Routes.character_path(conn, :delete, character.id),
      method: "delete",
      title: "Remove Character"
  end
end
