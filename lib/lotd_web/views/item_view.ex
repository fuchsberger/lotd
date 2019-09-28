defmodule LotdWeb.ItemView do
  use LotdWeb, :view

  alias Lotd.Gallery.Item

  def item_actions(conn, %Item{} = i) do
    [btn_edit(conn, i), btn_delete(conn, i)]
  end

  def item_name(%Item{} = i) do
    if i.url, do: link(i.name, to: i.url, target: "_blank"), else: "#{i.name}"
  end

  defp btn_edit(conn, %Item{} = item) do
    link icon("pencil"),
      to: Routes.item_path(conn, :edit, item.id),
      title: "Edit Item"
  end

  defp btn_delete(conn, %Item{} = item) do
    link icon("cancel", class: "has-text-danger"),
      to: Routes.item_path(conn, :delete, item.id),
      method: "delete",
      title: "Remove Item"
  end
end
