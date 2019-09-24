defmodule LotdWeb.AuthController do
  use LotdWeb, :controller

  @doc """
  Part 1
  if valid session token already, simply ignore request and return to index.
  if session token, but invalid, delete session and do part 2.
  if no session token do part 2.

  Part 2
  connect to nexus to retrieve api key and loads username and userid.
  Checks if already in database
    if not, create user, login and send session token back to client
    if yes, login and send session token back to client

    NOTE: it seems like a nexus api-key is valid for a full year --> nothing to do about expirey
  """
  def login(conn, %{"api_key" => api_key}) do

    url = Application.get_env(:lotd, Lotd.NexusAPI)[:user_url]
    header = Application.get_env(:lotd, Lotd.NexusAPI)[:header] |> Keyword.put(:apikey, api_key)

    case HTTPoison.get(url, header) do
      {:ok, response} ->
        response = Jason.decode!(response.body)
        json(conn, %{
          name: response["name"],
          user_id: response["user_id"]
        })
      {:error, _response} ->
        Logger.warn "something went wrong!"
        render(conn, PageView, "index.html")
    end
  end
end
