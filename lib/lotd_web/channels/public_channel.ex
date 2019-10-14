defmodule LotdWeb.PublicChannel do
  use LotdWeb, :channel

  alias Lotd.{Accounts, Gallery, Skyrim}
  alias LotdWeb.{DisplayView, ItemView, LocationView, QuestView}

  def join("public", _params, socket) do
    displays = Gallery.list_displays()
    items = Gallery.list_items()
    locations = Skyrim.list_locations()
    quests = Skyrim.list_quests()

    {:ok, %{
      admin: admin?(socket),
      moderator: moderator?(socket),
      user: authenticated?(socket) && socket.assigns.user.id,
      displays: Phoenix.View.render_many(displays, DisplayView, "display.json" ),
      items: Phoenix.View.render_many(items, ItemView, "item.json" ),
      locations: Phoenix.View.render_many(locations, LocationView, "location.json" ),
      quests: Phoenix.View.render_many(quests, QuestView, "quest.json" )
    }, assign(socket, :joined_public, true)}
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
