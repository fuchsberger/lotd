defmodule LotdWeb.SessionController do
  use LotdWeb, :controller

  alias Lotd.Accounts
  alias LotdWeb.Auth
  alias LotdWeb.PageView

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
                |> redirect(to: Routes.page_path(conn, :index))

              {:error, _changeset} ->
                conn
                |> put_flash(:error, "Could not create user in database!")
                |> render(PageView, "index.html")
            end
          # user found --> authenticate
          user ->
            conn
            |> Auth.login(user)
            |> redirect(to: Routes.page_path(conn, :index))
        end

      {:error, _response} ->
        conn
        |> put_flash(:error, "Nexus refused the request or invalid authentication token.")
        |> render(PageView, "index.html")
    end
  end

  # defp authenticate(conn) do
  #   if conn.assigns.current_user do
  #     conn
  #   else
  #     conn
  #     |> put_flash(:error, "You must be logged in to access that page")
  #     |> redirect(to: Routes.page_path(conn, :index))
  #     |> halt()
  #   end
  # end

  def delete(conn, _) do
    conn
    |> Auth.logout()
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
