defmodule LotdWeb.Api.DisplayView do
  use LotdWeb, :view

  def render("displays.json", %{displays: displays}) do
    %{
      data: render_many(displays, LotdWeb.Api.DisplayView, "display.json")
    }
  end

  def render("display.json", %{display: display}) do
    [
      display.items,
      display.name,
      display.room_id,
      display.id
    ]
  end
end
