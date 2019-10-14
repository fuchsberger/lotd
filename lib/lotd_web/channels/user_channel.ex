defmodule LotdWeb.UserChannel do
  use LotdWeb, :channel

  alias Lotd.{Accounts, Gallery, Skyrim}
  alias LotdWeb.{CharacterView, ModView}

  def join("user:" <> user_id, _params, socket) do
    if authenticated?(socket) && socket.assigns.user.id == String.to_integer(user_id) do
      characters = Accounts.list_user_characters(socket.assigns.user)
      mods = Skyrim.list_mods()

      {:ok, %{
        character_id: socket.assigns.user.active_character_id,
        characters: Phoenix.View.render_many(characters, CharacterView, "character.json" ),
        mods: Phoenix.View.render_many(mods, ModView, "mod.json" )
      }, assign(socket, :joined_user, true)}
    else
      {:error, %{ reason: "You must be authenticated to join this channel." }}
    end
  end

  def handle_in("collect_item", %{ "id" => id}, socket) do
    if character(socket) do
      Accounts.get_active_character(socket.assigns.user)
      |> Accounts.update_character_add_item(Gallery.get_item!(id))
      {:reply, :ok, socket}
    else
      {:reply, :error, socket}
    end
  end

  def handle_in("remove_item", %{ "id" => id}, socket) do
    if character(socket) do
      Accounts.get_active_character(socket.assigns.user)
      |> Accounts.update_character_remove_item(id)
      {:reply, :ok, socket}
    else
      {:reply, :error, socket}
    end
  end

  def handle_in("logout", _params, socket) do
    LotdWeb.Endpoint.broadcast("user_socket:" <> socket.assigns.user.id, "disconnect", %{})
  end
end
