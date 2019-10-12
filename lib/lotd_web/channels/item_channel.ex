defmodule LotdWeb.ItemChannel do
  use LotdWeb, :channel

  alias Lotd.{Accounts, Gallery}
  alias LotdWeb.ItemView

  def join("items", _params, socket) do

    if character(socket) do
      citems = Accounts.get_character_item_ids(character(socket))

      items = character(socket).mods
      |> Enum.map(fn m -> m.id end)
      |> Gallery.list_items()
      |> Phoenix.View.render_many(ItemView, "item.json", character_items: citems )

      {:ok, %{ items: items, moderator: moderator?(socket) }, socket}
    else
      items = Phoenix.View.render_many(Gallery.list_items(), ItemView, "item.json" )
      {:ok, %{ items: items, moderator: moderator?(socket) }, socket}
    end
  end

  def handle_in("collect", %{ "id" => id}, socket) do
    if character(socket) do
      Accounts.update_character_add_item(character(socket), Gallery.get_item!(id))
      {:reply, :ok, socket}
    else
      {:reply, :error, socket}
    end
  end

  def handle_in("remove", %{ "id" => id}, socket) do
    if character(socket) do
      Accounts.update_character_remove_item(character(socket), id)
      {:reply, :ok, socket}
    else
      {:reply, :error, socket}
    end
  end

  def handle_in("add", item_params, socket) do
    if moderator?(socket) do
      case Gallery.create_item(item_params) do
        {:ok, item} ->
          item = Phoenix.View.render_one(item, ItemView, "item.json")
          broadcast(socket, "add", %{ item: item})
          {:reply, :ok, socket}
        {:error, %Ecto.Changeset{} = changeset} ->
          {:reply, {:error, %{errors: error_map(changeset)}}, socket}
      end
    else
      {:reply, :error, socket}
    end
  end

  def handle_in("delete", %{ "id" => id}, socket) do
    if admin?(socket) do
      {:ok, item} = Gallery.get_item!(id) |> Gallery.delete_item()
      broadcast(socket, "delete", %{ id: item.id})
      {:reply, :ok, socket}
    else
      {:reply, :error, socket}
    end
  end
end
