defmodule LotdWeb.ItemController do
  use LotdWeb, :controller

  alias Lotd.Gallery
  alias Lotd.Gallery.Item

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns.current_user]
    apply(__MODULE__, action_name(conn), args)
  end

  def home(conn, _params, _current_user), do: redirect(conn, to: Routes.item_path(conn, :index))

  def index(conn, _params, _current_user) do
    items = Gallery.list_items()
    render(conn, "index.html", items: items)
  end

  def new(conn, _params, _current_user) do
    changeset = Gallery.change_item(%Item{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"item" => item_params}, _current_user) do
    case Gallery.create_item(item_params) do
      {:ok, item} ->
        conn
        |> put_flash(:info, "#{item.name} created.")
        |> redirect(to: Routes.item_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  # def update(conn, %{"id" => id}, current_user) do
  #   character =  Accounts.get_user_character!(current_user, id)
  #   case Accounts.activate_character(current_user, character) do
  #     {:ok, _user} ->
  #       conn
  #       |> put_flash(:info, "#{character.name} is hunting relics...")
  #       |> redirect(to: Routes.character_path(conn, :index))
  #     {:error, _reason} ->
  #       conn
  #       |> put_flash(:info, "Error: TODO: improve this...")
  #       |> redirect(to: Routes.character_path(conn, :index))
  #   end
  # end

  # def delete(conn, %{"id" => id}, current_user) do

  #   # if this is the active character, remove it from user as well
  #   if current_user.active_character_id == String.to_integer(id) do
  #     Accounts.update_user(current_user, %{ active_character_id: nil })
  #   end

  #   character = Accounts.get_user_character!(current_user, id)
  #   {:ok, _character} = Accounts.delete_character(character)

  #   conn
  #   |> put_flash(:info, "Character deleted successfully.")
  #   |> redirect(to: Routes.character_path(conn, :index))
  # end
end
