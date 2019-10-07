defmodule LotdWeb.PublicChannel do
  use LotdWeb, :channel

  alias Lotd.{Gallery, Repo}
  alias LotdWeb.ItemView

  def join("public", _params, socket) do
    if character(socket) do
      character = Repo.preload(character(socket), :mods)
      citems = Enum.map(character.items, fn i -> i.id end)

      items = character.mods
      |> Enum.map(fn m -> m.id end)
      |> Gallery.list_items()
      |> Phoenix.View.render_many(ItemView, "item.json", character_items: citems )

      {:ok, %{ items: items }, socket}
    else
      items = Phoenix.View.render_many(Gallery.list_items(), ItemView, "item.json" )
      {:ok, %{ items: items }, socket}
    end
  end
end
