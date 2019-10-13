defmodule LotdWeb.ItemView do
  use LotdWeb, :view

  def render("item.json", %{ item: i }) do
    %{
      id: i.id,
      name: i.name,
      url: i.url,
      location_id: i.location_id,
      quest_id: i.quest_id,
      mod_id: i.mod_id,
      display_id: i.display_id
    }
  end
end
