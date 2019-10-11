defmodule LotdWeb.ItemChannel do
  use LotdWeb, :channel

  alias Lotd.{Accounts, Gallery, Repo}
  alias LotdWeb.ItemView

  def join("items", %{ "loaded" => true }, socket) do
    {:ok, socket}
  end

  def join("items", _params, socket) do

    if character(socket) do
      citems = Enum.map(character(socket).items, fn i -> i.id end)

      items = character(socket).mods
      |> Enum.map(fn m -> m.id end)
      |> Gallery.list_items()
      |> Phoenix.View.render_many(ItemView, "item.json", character_items: citems )

      {:ok, %{ items: items }, socket}
    else
      items = Phoenix.View.render_many(Gallery.list_items(), ItemView, "item.json" )
      {:ok, %{ items: items }, socket}
    end
  end

  def handle_in("collect", %{ "id" => id}, socket) do
    if character(socket) do
      items = character(socket).items ++ [Gallery.get_item!(id)]
      Accounts.update_character(character(socket), :items, items)
      character = Map.put(character(socket), :items, items)
      user = Map.put(socket.assigns.user, :active_character, character)
      {:reply, :ok, assign(socket, :user, user)}
    else
      {:reply, :error, socket}
    end
  end

  def handle_in("remove", %{ "id" => id}, socket) do
    if character(socket) do
      items = Enum.reject(character(socket).items, fn i -> i.id == id end)
      Accounts.update_character(character(socket), :items, items)
      character = Map.put(character(socket), :items, items)
      user = Map.put(socket.assigns.user, :active_character, character)
      {:reply, :ok, assign(socket, :user, user)}
    else
      {:reply, :error, socket}
    end
  end
end
