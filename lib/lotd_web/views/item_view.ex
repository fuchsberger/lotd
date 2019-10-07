defmodule LotdWeb.ItemView do
  use LotdWeb, :view

  alias Lotd.Gallery.Item

  def render("item.json", %{ item: i, character_items: citems }) do
    [
      i.id,
      Enum.member?(citems, i.id),
      i.name,
      (if i.location, do: i.location.name, else: ""),
      (if i.quest, do: i.quest.name, else: ""),
      i.display.name
    ]
  end

  def render("item.json", %{ item: i }) do
    [
      i.id,
      i.name,
      (if i.location, do: i.location.name, else: ""),
      (if i.quest, do: i.quest.name, else: ""),
      i.display.name
    ]
  end

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
