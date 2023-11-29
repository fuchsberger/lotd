defmodule LotdWeb.ItemController do
  use LotdWeb, :controller

  alias Lotd.Gallery
  alias Lotd.Gallery.Item

  action_fallback LotdWeb.ErrorController

  def index(conn, _params), do: render(conn, "index.html", action: nil)

  def new(conn, _params) do
    items = Gallery.list_items()
    location_options = Gallery.list_locations() |> Enum.map(& {&1.name, &1.id})
    mod_options = Gallery.list_mods() |> Enum.map(& {&1.name, &1.id})

    changeset = Gallery.change_item(%Item{})
    render(conn, "index.html", action: :create, changeset: changeset, items: items,  location_options: location_options, mod_options: mod_options)
  end

  def create(conn, %{"item" => item_params}) do
    items = Gallery.list_items()

    case Gallery.create_item(item_params) do
      {:ok, _item} ->
        conn
        |> put_flash(:info, "Item created successfully.")
        |> redirect(to: ~p"/")

      {:error, %Ecto.Changeset{} = changeset} ->
        location_options = Gallery.list_locations() |> Enum.map(& {&1.name, &1.id})
        mod_options = Gallery.list_mods() |> Enum.map(& {&1.name, &1.id})

        render(conn, "index.html", action: :create, changeset: changeset, items: items, location_options: location_options, mod_options: mod_options)
    end
  end

  def edit(conn, %{"id" => id}) do
    with items <- Gallery.list_items(),
        %Item{} = item <- Gallery.get_item!(id) do


      location_options = Gallery.list_locations() |> Enum.map(& {&1.name, &1.id})
      mod_options = Gallery.list_mods() |> Enum.map(& {&1.name, &1.id})

      changeset = Gallery.change_item(item)
      render(conn, "index.html", action: :update, changeset: changeset, item: item, items: items, location_options: location_options, mod_options: mod_options)
    end
  end

  def update(conn, %{"id" => id, "item" => item_params}) do
    with items <- Gallery.list_items(),
        %Item{} = item <- Gallery.get_item!(id) do
      case Gallery.update_item(item, item_params) do
        {:ok, _item} ->
          conn
          |> put_flash(:info, "Item updated successfully.")
          |> redirect(to: ~p"/")

        {:error, %Ecto.Changeset{} = changeset} ->
          location_options = Gallery.list_locations() |> Enum.map(& {&1.name, &1.id})
          mod_options = Gallery.list_mods() |> Enum.map(& {&1.name, &1.id})

          render(conn, "index.html", action: :update, changeset: changeset, item: item, items: items, location_options: location_options, mod_options: mod_options)
      end
    end
  end

  def remove(conn, %{"id" => id}) do
    with items <- Gallery.list_items(),
        %Item{} = item <- Gallery.get_item!(id) do
      render(conn, "index.html", action: :delete, item: item, items: items)
    end
  end

  def delete(conn, %{"id" => id}) do
    with %Item{} = item <- Gallery.get_item!(id),
        {:ok, _item} = Gallery.delete_item(item)
    do
      conn
      |> put_flash(:info, "Item deleted successfully.")
      |> redirect(to: ~p"/")
    end
  end
end
