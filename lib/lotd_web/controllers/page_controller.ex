defmodule LotdWeb.PageController do
  use LotdWeb, :controller

  alias Lotd.Accounts
  alias Lotd.Accounts.Character

  alias Lotd.Gallery
  alias Lotd.Gallery.{Display, Item, ItemFilter, Location, Mod, Region, Room}

  def about(conn, _params) do
    render(conn, "about.html")
  end

  def character(conn, _params) do
    render conn, "character.html", changeset: Accounts.change_character(%Character{})
  end

  def display(conn, _params) do
    render conn, "display.html",
      changeset: Gallery.change_display(%Display{}),
      item_options: Gallery.item_options(),
      room_options: Gallery.room_options()
  end

  def gallery(conn, _params) do
    redirect conn, to: Routes.page_path(conn, :item)
  end

  def item(conn, _params) do
    render conn, "item.html",
      changeset: Gallery.change_item(%Item{}),
      display_options: Gallery.display_options(),
      filter_changeset: Gallery.change_item_filter(%ItemFilter{}),
      location_options: Gallery.location_options(),
      mod_options: Gallery.mod_options(),
      region_options: Gallery.region_options(),
      room_options: Gallery.room_options()
  end

  def location(conn, _params) do
    render conn, "location.html",
      changeset: Gallery.change_location(%Location{}),
      item_options: Gallery.item_options(),
      region_options: Gallery.region_options()
  end

  def mod(conn, _params) do
    render conn, "mod.html", changeset: Gallery.change_mod(%Mod{})
  end

  def region(conn, _params) do
    render conn, "region.html",
      changeset: Gallery.change_region(%Region{}),
      location_options: Gallery.location_options(),
      regions: Gallery.list_regions()
  end

  def room(conn, _params) do
    render conn, "room.html",
      changeset: Gallery.change_room(%Room{}),
      display_options: Gallery.display_options(),
      rooms: Gallery.list_rooms()
  end
end
