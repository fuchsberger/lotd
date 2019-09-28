defmodule LotdWeb.CharacterView do
  use LotdWeb, :view

  alias Lotd.Accounts.Character

  def character_actions(conn, %Character{} = c) do
    [btn_activate(conn, c), btn_delete(conn, c)]
  end

  defp btn_activate(conn, character) do
    u = conn.assigns.current_user

    if u.active_character_id == character.id do
      icon("star", class: "has-text-link", title: "Active Character")
    else
      link icon("star-empty", class: "has-text-dark"),
        to: Routes.character_path(conn, :update, character.id),
        method: "put",
        title: "Activate"
    end
  end

  defp btn_delete(conn, character) do
    link icon("cancel", class: "has-text-danger"),
      to: Routes.character_path(conn, :delete, character.id),
      method: "delete",
      title: "Remove Character"
  end
end
