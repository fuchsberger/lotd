defmodule LotdWeb.PublicChannel do
  use LotdWeb, :channel

  alias Phoenix.View
  alias Lotd.{Gallery, Skyrim}

  def join("public", _params, socket) do

    displays = Gallery.list_displays()
    items = Gallery.list_items()
    locations = Skyrim.list_locations()
    quests = Skyrim.list_quests()
    mods = Skyrim.list_mods()

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
