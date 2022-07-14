defmodule LotdWeb.Api.ItemController do
  use LotdWeb, :controller

  alias Lotd.Accounts
  alias Lotd.Gallery
  alias Lotd.Gallery.Item
  alias LotdWeb.Api.ItemView

  def index(conn, _params) do
    {items, character_item_ids} =
      if conn.assigns.current_user do
        character_item_ids =
          if conn.assigns.current_user.active_character,
            do: conn.assigns.current_user.active_character.items,
            else: []
        { Gallery.list_items(conn.assigns.current_user.mods), character_item_ids }
      else
        { Gallery.list_items(), [] }
      end

    render(conn, "items.json", items: items, character_item_ids: character_item_ids)
  end

  def create(conn, %{"item" => item_params}) do
    case Gallery.create_item(item_params) do
      {:ok, item} ->
        item = Gallery.preload_item(item)
        json(conn, %{success: true, item: ItemView.render("item.json",
        item: item, user_item_ids: conn.assigns.current_user.items )})

      {:error, %Ecto.Changeset{} = _changeset} ->
        json(conn, %{success: false})
    end
  end

  def update(conn, %{"id" => id, "item" => item_params}) do
    with %Item{} = item <- Gallery.get_item!(id) do
      case Gallery.update_item(item, item_params) do
        {:ok, item} ->
          item = Gallery.preload_item(item)
          json(conn, %{success: true, item: ItemView.render("item.json",
          item: item, user_item_ids: conn.assigns.current_user.items )})

        {:error, %Ecto.Changeset{} = _changeset} ->
          json(conn, %{success: false})
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    with %Item{} = item <- Gallery.get_item!(id),
        {:ok, item} = Gallery.delete_item(item) do
      json(conn, %{deleted_id: item.id})
    end
  end


  def toggle(conn, %{"item_id" => id}) do
    collected = Accounts.toggle_item!(conn.assigns.current_user.active_character, id)
    Accounts.refresh_character!(conn.assigns.current_user.active_character)

    conn
    |> put_status(200)
    |> json(%{collected: collected})
  end
end
