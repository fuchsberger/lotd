defmodule LotdWeb.QuestView do
  use LotdWeb, :view

  def render("quest.json", %{ quest: q }) do
    %{
      id: q.id,
      name: q.name,
      url: q.url,
      mod_id: q.mod_id
    }
  end
end
