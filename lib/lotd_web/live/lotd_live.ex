defmodule LotdWeb.LotdLive do
  use LotdWeb, :live_view

  alias Lotd.Accounts

  def mount(_params, params, socket) do

    user =
      if Map.has_key?(params, "user_token"),
        do: Accounts.get_user_by_session_token(params["user_token"]),
        else: nil

    {:ok, socket
    |> assign(:user, user)}
  end

end
