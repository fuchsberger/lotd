defmodule LotdWeb.QuestView do
  use LotdWeb, :view

  def render("quest.json", %{ quest: q }) do
    %{
      id: q.id,
      found: 0,
      count: 0,
      name: q.name,
      url: q.url,
      mod_id: q.mod_id
    }
  end
end
