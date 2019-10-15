defmodule LotdWeb.QuestController do
  use LotdWeb, :controller

  alias Lotd.Skyrim
  alias Lotd.Skyrim.Quest

  plug :load_mods when action in [:new, :create, :edit, :update]

  defp load_mods(conn, _), do: assign conn, :mods, Skyrim.list_mods()


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
