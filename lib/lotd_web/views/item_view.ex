defmodule LotdWeb.ItemView do
  use LotdWeb, :view

  alias Lotd.Gallery.Item

  def btn_collect(conn, %Item{} = i, character_item_ids) do
    if Enum.member?(character_item_ids, i.id) do
      link icon("ok-squared"),
        to: Routes.item_path(conn, :borrow, i.id),
        method: "put",
        title: "Remove from collection"

    else
      link icon("plus-squared-alt"),
        to: Routes.item_path(conn, :collect, i.id),
        method: "put",
        title: "Add to collection"
    end
  end

  def select_options(structures), do: for s <- structures, do: {s.name, s.id}

  def item_actions(conn, %Item{} = i) do
    [btn_edit(conn, i), btn_delete(conn, i)]
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
