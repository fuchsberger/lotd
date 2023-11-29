defmodule LotdWeb.PageController do
  use LotdWeb, :controller

  alias Lotd.Gallery
  alias Lotd.Gallery.{Item, ItemFilter, Location, Mod, Region}

  def about(conn, _params) do
    render(conn, "about.html")
  end

  def gallery(conn, _params) do
    redirect conn, to: ~p"/"
  end

  def item(conn, _params) do
    render conn, "item.html",
      changeset: Gallery.change_item(%Item{}),
      filter_changeset: Gallery.change_item_filter(%ItemFilter{}),
      location_options: Gallery.location_options(),
      mod_options: Gallery.mod_options(),
      region_options: Gallery.region_options()
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
end
