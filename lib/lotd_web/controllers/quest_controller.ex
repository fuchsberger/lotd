defmodule LotdWeb.QuestController do
  use LotdWeb, :controller

  alias Lotd.Skyrim
  alias Lotd.Skyrim.Quest

  def index(conn, _params) do
    character_item_ids = character_item_ids(conn)
    quests = Skyrim.list_alphabetical_quests()
    |> Enum.map(fn l ->
      quest_item_ids = Enum.map(l.items, fn i -> i.id end)
      common_ids = quest_item_ids -- character_item_ids
      common_ids = quest_item_ids -- common_ids
      Map.put(l, :character_item_count, Enum.count(common_ids))
    end)
    render(conn, "index.html", quests: quests)
  end

  def new(conn, _params) do
    changeset = Skyrim.change_quest(%Quest{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"quest" => quest_params}) do
    case Skyrim.create_quest(quest_params) do
      {:ok, _quest} ->
        redirect(conn, to: Routes.quest_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    quest = Skyrim.get_quest!(id)
    changeset = Skyrim.change_quest(quest)
    render(conn, "edit.html", changeset: changeset)
  end

  def update(conn, %{"id" => id, "quest" => quest_params}) do
    quest = Skyrim.get_quest!(id)
    case Skyrim.update_quest(quest, quest_params) do
      {:ok, _quest} ->
        redirect(conn, to: Routes.quest_path(conn, :index))
      {:error, changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    quest = Skyrim.get_quest!(id)
    {:ok, _quest} = Skyrim.delete_quest(quest)

    conn
    |> put_flash(:info, "Quest deleted successfully.")
    |> redirect(to: Routes.quest_path(conn, :index))
  end
end
