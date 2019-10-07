# defmodule LotdWeb.CharacterChannel do
#   use LotdWeb, :channel

#   def join("user", _params, socket) do
#     if Map.has_key?(socket.assigns, :user),
#       do: {:ok, socket},
#       else: {:error, %{ reason: "You must be authenticated to join this channel."}}
#   end

#   def handle_in("logout", _params, socket) do
#   IO.inspect "LOGOUT"
#     LotdWeb.Endpoint.broadcast("user_socket:" <> socket.assigns.user.id, "disconnect", %{})
#   end
# end
