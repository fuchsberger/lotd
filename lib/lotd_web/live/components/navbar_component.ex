defmodule LotdWeb.NavbarComponent do
  use Phoenix.LiveComponent

  def handle_event("toggle_modal", _params, socket) do
    send self(), {:toggle_modal, %{}}
    {:noreply, socket}
  end

  def render(assigns) do
    Phoenix.View.render(LotdWeb.LayoutView, "navbar.html", assigns)
  end
end
