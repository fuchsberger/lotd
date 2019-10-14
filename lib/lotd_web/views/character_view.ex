defmodule LotdWeb.CharacterView do
  use LotdWeb, :view

  def render("character.json", %{ character: c }) do
    %{
      id: c.id,
      name: c.name,
      items_found: Enum.count(c.items)
    }
  end

  def character_actions(conn, %Lotd.Accounts.Character{} = c) do
    [btn_activate(conn, c), btn_edit(conn, c),btn_delete(conn, c)]
  end

  defp btn_activate(conn, character) do
    if character(conn).id == character.id do
      icon("star", class: "has-text-link", title: "Active Character")
    else
      link icon("star-empty", class: "has-text-dark"),
        to: Routes.character_path(conn, :activate, character.id),
        method: "put",
        title: "Activate"
    end
  end

  defp btn_edit(conn, character) do
    link icon("pencil", class: "has-text-dark"),
      to: Routes.character_path(conn, :edit, character.id),
      title: "Edit"
  end

  defp btn_delete(conn, character) do
    if character(conn).id != character.id do
      link icon("cancel", class: "has-text-danger"),
        to: Routes.character_path(conn, :delete, character.id),
        method: "delete",
        title: "Remove Character"
    else
      ""
    end
  end
end
