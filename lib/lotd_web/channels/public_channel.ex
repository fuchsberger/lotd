defmodule LotdWeb.PublicChannel do
  use LotdWeb, :channel

  alias Lotd.{Gallery, Skyrim}
  alias LotdWeb.{DisplayView, ItemView, ModView, LocationView, QuestView}

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
      displays: Phoenix.View.render_many(displays, DisplayView, "display.json" ),
      items: Phoenix.View.render_many(items, ItemView, "item.json" ),
      locations: Phoenix.View.render_many(locations, LocationView, "location.json" ),
      quests: Phoenix.View.render_many(quests, QuestView, "quest.json" ),
      mods: Phoenix.View.render_many(mods, ModView, "mod.json" )
    }, socket}
  end
end
