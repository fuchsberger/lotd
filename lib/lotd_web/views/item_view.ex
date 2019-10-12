defmodule LotdWeb.ItemView do
  use LotdWeb, :view

  alias Lotd.Repo
  alias Lotd.Gallery.Item

  def render("item.json", %{ item: i, character_items: citems }) do
    [
      i.id,
      i.name,
      i.url,
      (if i.location, do: i.location.name, else: nil),
      (if i.quest, do: i.quest.name, else: nil),
      i.display.name,
      Enum.member?(citems, i.id)
    ]
  end

  def render("item.json", %{ item: i }) do
    i = Repo.preload(i, :display)
    [
      i.id,
      i.name,
      i.url,
      (if Ecto.assoc_loaded?(i.location), do: i.location.name, else: nil),
      (if Ecto.assoc_loaded?(i.quest), do: i.quest.name, else: nil),
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
