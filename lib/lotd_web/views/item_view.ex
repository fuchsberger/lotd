defmodule LotdWeb.ItemView do
  use LotdWeb, :view

  alias Lotd.Gallery.Item

  def item_actions(conn, %Item{} = i) do
    [btn_delete(conn, i)]
  end

  def item_name(%Item{} = i) do
    if i.url, do: link(i.name, to: i.url, target: "_blank"), else: "#{i.name}"
  end

  # defp btn_activate(conn, character) do
  #   u = conn.assigns.current_user

  #   if u.active_character_id == character.id do
  #     icon("star", class: "has-text-link", title: "Active Character")
  #   else
  #     link icon("star-empty", class: "has-text-dark"),
  #       to: Routes.character_path(conn, :update, character.id),
  #       method: "put",
  #       title: "Activate"
  #   end
  # end

  defp btn_delete(conn, %Item{} = item) do
    link icon("cancel", class: "has-text-danger"),
      to: Routes.item_path(conn, :delete, item.id),
      method: "delete",
      title: "Remove Item"
  end
end
