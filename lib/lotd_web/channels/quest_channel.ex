defmodule LotdWeb.QuestChannel do
  use LotdWeb, :channel

  alias Phoenix.View
  alias Lotd.{Accounts, Museum}

  def join("quest", _params, socket) do
    found_ids = if authenticated?(socket) do
      socket.assigns.user
      |> Accounts.get_user_character!(socket.assigns.user.active_character_id)
      |> Accounts.load_quest_ids()
    else
      []
    end

    quests = Museum.list_quests()
    |> View.render_many(DataView, "quest.json", found_ids: found_ids)

    {:ok, %{ quests: quests}, socket}
  end
end
