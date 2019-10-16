defmodule LotdWeb.DisplayView do
  use LotdWeb, :view

  def render("display.json", %{ display: d }) do
    %{
      id: d.id,
      name: d.name,
      url: d.url,
      found: 0,
      count: 0
    }
  end
end
