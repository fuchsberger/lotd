defmodule LotdWeb.SearchbarComponent do
  use Phoenix.LiveComponent

  def handle_event("search", %{"search_field" => %{"query" => query}}, socket) do
    send self(), {:search, query}
    { :noreply, socket }
  end

  def handle_event("toggle_modal", _params, socket) do
    send self(), {:toggle_modal, %{}}
    {:noreply, socket}
  end

  def render(assigns), do: Phoenix.View.render(LotdWeb.LayoutView, "searchbar.html", assigns)
end
