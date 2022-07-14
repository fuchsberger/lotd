defmodule LotdWeb.PageController do
  use LotdWeb, :controller

  alias Lotd.Accounts
  alias Lotd.Accounts.Character

  alias Lotd.Gallery
  alias Lotd.Gallery.{Display, Item, Location, Mod, Region, Room}

  def about(conn, _params) do
    render(conn, "about.html")
  end

  def character(conn, _params) do
    render conn, "character.html", changeset: Accounts.change_character(%Character{})
  end

  def display(conn, _params) do
    render conn, "display.html", changeset: Gallery.change_display(%Display{})
  end

  def item(conn, _params) do
    render conn, "item.html", changeset: Gallery.change_item(%Item{})
  end

  def location(conn, _params) do
    render conn, "location.html", changeset: Gallery.change_location(%Location{})
  end

  def mod(conn, _params) do
    render conn, "mod.html", changeset: Gallery.change_mod(%Mod{})
  end

  def region(conn, _params) do
    render conn, "region.html", changeset: Gallery.change_region(%Region{})
  end

  def room(conn, _params) do
    render conn, "room.html", changeset: Gallery.change_room(%Room{})
  end
end
