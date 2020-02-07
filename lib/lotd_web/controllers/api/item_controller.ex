defmodule LotdWeb.Api.ItemController do
  use LotdWeb, :controller

  alias Lotd.{Accounts, Gallery, Repo}

  def index(conn, _params) do
    if is_nil(conn.assigns.current_user) do
      render conn, "index.json", items: Gallery.list_items()
    else
      items =
        conn.assigns.current_user.active_character_id
        |> Accounts.get_character!(:mods)
        |> Gallery.list_items()

      render conn, "index.json", items: items
    end
  end

  def show(conn, %{"id" => id}) do
    item = Gallery.get_item!(id)
    render(conn, "show.json", item: item)
  end
end
