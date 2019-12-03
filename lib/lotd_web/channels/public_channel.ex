defmodule LotdWeb.PublicChannel do
  use LotdWeb, :channel

  alias Phoenix.View
  alias Lotd.Museum

  def join("public", _params, socket) do

    displays = Museum.list_displays()
    items = Museum.list_items()
    locations = Museum.list_locations()
    quests = Museum.list_quests()
    mods = Museum.list_mods()

    {:ok, %{
      admin: admin?(socket),
      moderator: moderator?(socket),
      user: authenticated?(socket) && socket.assigns.user.id,
      displays: View.render_many(displays, DataView, "display.json" ),
      items: View.render_many(items, DataView, "item.json" ),
      locations: View.render_many(locations, DataView, "location.json" ),
      quests: View.render_many(quests, DataView, "quest.json" ),
      mods: View.render_many(mods, DataView, "mod.json" )
    }, socket}
  end
end
