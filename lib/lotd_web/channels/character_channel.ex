defmodule LotdWeb.CharacterChannel do
  use LotdWeb, :channel

  alias Phoenix.View
  alias Lotd.Accounts

  def join("character", _params, socket) do
    if authenticated?(socket) do
      characters = Accounts.list_user_characters(socket.assigns.user)
      {:ok, %{ characters: View.render_many(characters, DataView, "character.json" ) }, socket}
    else
      {:error, %{ reason: "You must be authenticated to join this channel." }}
    end
  end
end
