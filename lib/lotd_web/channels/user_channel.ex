defmodule LotdWeb.UserChannel do
  use LotdWeb, :channel

  def join("user", _params, socket) do
    if Map.has_key?(socket.assigns, :user_id),
      do: {:ok, socket},
      else: {:error, %{ reason: "You must be authenticated to join this channel."}}
  end
end
