defmodule LotdWeb.ModView do
  use LotdWeb, :view

  def render("mod.json", %{ mod: m }) do
    %{
      active: false,
      id: m.id,
      filename: m.filename,
      name: m.name,
      url: m.url
    }
  end

  def user_actions(conn, %Lotd.Skyrim.Mod{} = m) do
    cond do
      m.id <= 5 ->
        icon("ok-squared")
      Enum.member?(conn.assigns.character_mod_ids, m.id) ->
        link icon("ok-squared"),
          to: Routes.mod_path(conn, :deactivate, m.id),
          method: "put",
          title: "Remove"
      true ->
        link icon("plus-squared-alt"),
          to: Routes.mod_path(conn, :activate, m.id),
          method: "put",
          title: "Activate"
    end
  end

  def admin_actions(conn, struct) do
    edit_path = get_path(conn, :edit, id: struct.id)
    delete_path = get_path(conn, :delete, id: struct.id)

    content_tag :td, [
      link(icon("pencil"), to: edit_path),
      link(icon("cancel", class: "has-text-danger"), to: delete_path, method: "delete")
    ]
  end
end
