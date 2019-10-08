defmodule LotdWeb.UserSocket do
  use Phoenix.Socket

  ## Channels
  channel "items", LotdWeb.ItemChannel

  @max_age 2 * 7 * 24 * 60 * 60

  # authorized login stores user_id in socket
  def connect(%{"token" => token}, socket, _connect_info) do
    case Phoenix.Token.verify(socket, "user_socket", token, max_age: @max_age) do
      {:ok, user_id} ->
        user = Lotd.Accounts.get_user!(user_id)
        {:ok, assign(socket, :user, user)}

      {:error, _reason} ->
        # also allow anonymous connection on invalid or missing token
        {:ok, socket}
    end
  end

  def connect(_params, socket, _connect_info), do: {:ok, socket}

  def character(socket), do:
    if Map.has_key?(socket.assigns, :user), do: socket.assigns.user.active_character, else: nil

  # authenticated users should be able to be recogized so that on a logout all sockets are disconnected.
  def id(socket) do
    if Map.has_key?(socket.assigns, :user),
      do: "user_socket:#{socket.assigns.user.id}",
      else: nil
  end
end
