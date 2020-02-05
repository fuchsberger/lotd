defmodule LotdWeb.ItemsLive do
  use Phoenix.LiveView, container: {:div, class: "container"}

  alias Lotd.{Accounts, Gallery}

  def render(assigns), do: LotdWeb.ItemView.render("index.html", assigns)

  def mount(_params, %{"user_id" => user_id }, socket) do
    user = Accounts.get_user!(user_id)

    items = if user.moderator,
      do: Gallery.list_items(),
      else: Gallery.list_items(user.active_character.mods)

    {:ok, assign(socket, :items, items)}
  end

  def mount(_params, _session, socket) do
    items = Gallery.list_items()
    {:ok, assign(socket, :items, items)}
  end
end
