defmodule LotdWeb.UserSessionController do
  use LotdWeb, :controller

  alias Lotd.Accounts
  alias LotdWeb.UserAuth

  @doc """
  connect to nexus to test api key and return username, userid and avatar_url.
  Checks if ok check if user_id already in database
    if not, create user, login and send session token back to client
    if yes, login and send session token back to client
  """
  def create(conn, %{"session" => %{"api_key" => api_key}}) do
    url = Application.get_env(:lotd, Lotd.NexusAPI)[:user_url]
    header =
      Application.get_env(:lotd, Lotd.NexusAPI)[:header]
      |> Keyword.put(:apikey, api_key)

    case HTTPoison.get(url, header) do
      {:ok, response} ->
        # response contains nexus user information such as userid and name
        response = Jason.decode!(response.body)

        id = response["user_id"]
        avatar_url = Map.get(response, "profile_url")
        user_name = response["name"]

        case Accounts.get_user(id) do
          # no record found --> create it and authenticate
          nil ->
            case Accounts.create_user(%{id: id, avatar_url: avatar_url, username: user_name}) do
              {:ok, user} ->
                # login and redirect to gallery page
                conn
                |> UserAuth.log_in_user(user)

              {:error, _changeset} ->
                conn
                |> put_flash(:error, "Error: Could not create user in database!")
                |> redirect(to: ~p"/")
                |> halt()
            end
          # user found --> authenticate
          user ->
            case Accounts.update_user(user, %{avatar_url: avatar_url, username: user_name}) do
              {:error, _changeset} ->
                conn
                |> put_flash(:error, "Error: Could not update user!")
                |> redirect(to: ~p"/")
                |> halt()

              {:ok, user} ->
                conn
                |> UserAuth.log_in_user(user)
            end
        end

      {:error, %HTTPoison.Error{reason: reason}} ->
        conn
        |> put_flash(:error, "Error connecting to Nexus: #{reason}")
        |> redirect(to: ~p"/")
        |> halt()
    end
  end

  def delete(conn, _) do
    conn
    |> put_flash(:info, gettext "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
