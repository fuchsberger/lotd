defmodule LotdWeb.LocationChannel do
  use LotdWeb, :channel

  alias Phoenix.View
  alias Lotd.{Accounts, Skyrim}

  def join("location", _params, socket) do
    found_ids = if authenticated?(socket) do
      socket.assigns.user
      |> Accounts.get_user_character!(socket.assigns.user.active_character_id)
      |> Accounts.load_location_ids()
    else
      []
    end

    locations = Skyrim.list_locations()
    |> View.render_many(DataView, "location.json", found_ids: found_ids)

    {:ok, %{ locations: locations}, socket}
  end
end
