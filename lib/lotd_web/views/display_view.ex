defmodule LotdWeb.DisplayView do
  use LotdWeb, :view

  alias Lotd.Museum

  def collected_count(user, display) do
    user.active_character.items
    |> Enum.filter(fn i -> i.display_id == display.id end)
    |> Enum.count()
  end
end
