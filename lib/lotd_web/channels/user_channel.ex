defmodule LotdWeb.UserChannel do
  use LotdWeb, :channel

  alias Lotd.{Accounts, Skyrim}
  alias LotdWeb.{CharacterView, ModView}

  def join("user:" <> user_id, _params, socket) do
    if authenticated?(socket) && socket.assigns.user.id == String.to_integer(user_id) do

      characters = Accounts.list_user_characters(socket.assigns.user)
      mods = Skyrim.list_mods()

      character = Accounts.get_active_character!(socket.assigns.user)
      character_items = Accounts.get_character_item_ids(character)
      character_mods = Accounts.get_character_mod_ids(character)

      {:ok, %{
        characters: Phoenix.View.render_many(characters, CharacterView, "character.json" ),
        character_items: character_items,
        character_mods: character_mods,
        mods: Phoenix.View.render_many(mods, ModView, "mod.json" )
      }, socket}
    else
      {:error, %{ reason: "You must be authenticated to join this channel." }}
    end
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

  def handle_in("logout", _params, socket) do
    LotdWeb.Endpoint.broadcast("user_socket:" <> socket.assigns.user.id, "disconnect", %{})
  end
end
