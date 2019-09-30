defmodule LotdWeb.ItemView do
  use LotdWeb, :view

  alias Lotd.Gallery.Item

  def btn_collect(conn, %Item{} = i, character_item_ids) do
    if Enum.member?(character_item_ids, i.id) do
      link icon("ok-squared"),
        to: Routes.item_path(conn, :borrow, i.id),
        method: "put",
        title: "Remove from collection",
        data: [test: "new val"]

    else
      link icon("plus-squared-alt"),
        to: Routes.item_path(conn, :collect, i.id),
        method: "put",
        title: "Add to collection",
        data: [test: "new val"]
    end
  end

  def display_select_options(displays) do
    for display <- displays, do: {display.name, display.id}
  end

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
