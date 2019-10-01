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
end
