defmodule LotdWeb.SessionController do
  use LotdWeb, :controller

  alias Lotd.Accounts
  alias LotdWeb.Auth

  @doc """
  connect to nexus to test api key and return username and userid.
  Checks if ok check if user_id already in database
    if not, create user, login and send session token back to client
    if yes, login and send session token back to client
  """
  def create(conn, %{"api_key" => api_key}) do

    url = Application.get_env(:lotd, Lotd.NexusAPI)[:user_url]
    header = Application.get_env(:lotd, Lotd.NexusAPI)[:header] |> Keyword.put(:apikey, api_key)

    case HTTPoison.get(url, header) do
      {:ok, response} ->
        # response contains nexus user information such as userid and name
        response = Jason.decode!(response.body)
        nexus_id = response["user_id"]
        nexus_name = response["name"]

        case Accounts.get_user_by(nexus_id: nexus_id) do
          # no record found --> create it and authenticate
          nil ->
            case Accounts.create_user(%{nexus_id: nexus_id, nexus_name: nexus_name}) do
              {:ok, user} ->
                conn
                |> Auth.login(user)
                |> redirect(to: Routes.character_path(conn, :new))

              {:error, _changeset} ->
                conn
                |> put_flash(:error, "Error: Could not create user in database!")
                |> redirect(to: Routes.item_path(conn, :index))
                |> halt()
            end
          # user found --> authenticate
          user ->
            conn
            |> Auth.login(user)
            |> redirect(to: Routes.item_path(conn, :index))
            |> halt()
        end

      {:error, %HTTPoison.Error{reason: reason}} ->
        conn
        |> put_flash(:error, "Error connecting to Nexus. #{reason}")
        |> redirect(to: Routes.item_path(conn, :index))
        |> halt()
    end
  end

  def delete(conn, _) do
    conn
    |> Auth.logout()
    |> redirect(to: Routes.item_path(conn, :index))
    |> halt()
  end
end
