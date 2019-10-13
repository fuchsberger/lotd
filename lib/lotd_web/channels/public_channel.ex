defmodule LotdWeb.PublicChannel do
  use LotdWeb, :channel

  alias Lotd.{Accounts, Gallery, Skyrim}
  alias LotdWeb.{DisplayView, ItemView, LocationView, QuestView, ModView}

  # citems = Accounts.get_character_item_ids(character(socket))
  # cmods = Enum.map(character(socket).mods, fn m -> m.id end)

  # items = character(socket).mods
  # |> Enum.map(fn m -> m.id end)
  # |> Gallery.list_items()
  # |> Phoenix.View.render_many(ItemView, "item.json", character_items: citems )

  # locations = Skyrim.list_locations(cmods)
  # |> calculate_found_items(citems)
  # |> Phoenix.View.render_many(LocationView, "location.json")

  # quests = Skyrim.list_quests(cmods)
  # |> calculate_found_items(citems)
  # |> Phoenix.View.render_many(QuestView, "quest.json")

  # {:ok, %{
  #   admin: admin?(socket),
  #   moderator: moderator?(socket),
  #   user: authenticated?(socket),
  #   items: items,
  #   locations: locations,
  #   quests: quests
  # }, socket}

  def join("public", _params, socket) do

    displays = Gallery.list_displays()
    items = Gallery.list_items()
    locations = Skyrim.list_locations()
    quests = Skyrim.list_quests()
    mods = Skyrim.list_mods()

    {:ok, %{
      admin: admin?(socket),
      moderator: moderator?(socket),
      user: authenticated?(socket),
      displays: Phoenix.View.render_many(displays, DisplayView, "display.json" ),
      items: Phoenix.View.render_many(items, ItemView, "item.json" ),
      locations: Phoenix.View.render_many(locations, LocationView, "location.json" ),
      quests: Phoenix.View.render_many(quests, QuestView, "quest.json" ),
      mods: Phoenix.View.render_many(mods, ModView, "mod.json" )
    }, socket}
  end

  defp calculate_found_items(collection, item_ids) do
    Enum.map(collection, fn c ->
      common_ids = c.items -- item_ids
      common_ids = c.items -- common_ids
      Map.put(c, :found_items, Enum.count(common_ids))
    end)
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
