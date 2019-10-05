defmodule LotdWeb.ItemView do
  use LotdWeb, :view

  alias Lotd.Gallery.Item

  def user_actions(conn, %Item{} = i) do
    btn =
      if Enum.member?(conn.assigns.character_items, i.id) do
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
    content_tag :td, btn
  end
end
