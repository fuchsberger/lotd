defmodule LotdWeb.DisplayView do
  use LotdWeb, :view

  def render("display.json", %{ display: d }) do
    %{
      id: d.id,
      name: d.name,
      url: d.url
    }
  end
end
