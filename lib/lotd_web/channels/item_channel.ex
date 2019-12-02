defmodule LotdWeb.ItemChannel do
  use LotdWeb, :channel

  alias Phoenix.View
  alias Lotd.Gallery

  def join("item", _params, socket) do
    cid = if authenticated?(socket), do: socket.assigns.user.active_character_id, else: nil
    items = Gallery.list_items()
    {:ok, %{ items: View.render_many(items, DataView, "item.json", cid: cid)}, socket}
  end
end
