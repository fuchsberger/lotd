defmodule LotdWeb.Api.ItemController do
  use LotdWeb, :controller

  alias Lotd.Gallery

  def index(conn, _params) do
    {items, character_item_ids} =
      if conn.assigns.current_user do
        character_item_ids =
          if conn.assigns.current_user.active_character,
            do: conn.assigns.current_user.active_character.items,
            else: []
        { Gallery.list_items(conn.assigns.current_user.mods), character_item_ids }
      else
        { Gallery.list_items(), [] }
      end

    render(conn, "items.json", items: items, character_item_ids: character_item_ids)
  end
end
