defmodule LotdWeb.PublicChannel do
  use LotdWeb, :channel

  def join("public", _params, socket) do
    {:ok, socket}
  end
end
