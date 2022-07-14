defmodule LotdWeb.PageController do
  use LotdWeb, :controller

  alias Lotd.Accounts
  alias Lotd.Accounts.Character

  alias Lotd.Gallery
  alias Lotd.Gallery.Mod

  def about(conn, _params) do
    render(conn, "about.html")
  end

  def character(conn, _params) do
    render conn, "character.html", changeset: Accounts.change_character(%Character{})
  end

  def mod(conn, _params) do
    render conn, "mod.html", changeset: Gallery.change_mod(%Mod{})
  end
end
