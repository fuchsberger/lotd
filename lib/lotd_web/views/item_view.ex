defmodule LotdWeb.ItemView do
  use LotdWeb, :view


  def check_item(moderator) do
    if moderator,
      do: icon("edit", class: "text-primary", phx_click: "toggle", phx_value_field: "moderate"),
      else: icon("active")
  end
end
