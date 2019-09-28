defmodule LotdWeb.CharacterView do
  use LotdWeb, :view

  alias Lotd.Accounts.Character

  def character_actions(conn, %Character{} = c) do
    [btn_delete(conn, c)]
  end


  defp btn_delete(conn, character) do
    link icon("user-times", class: "has-text-dark"),
      to: Routes.character_path(conn, :delete, character.id),
      method: "delete",
      title: "Remove Character"
  end
end
