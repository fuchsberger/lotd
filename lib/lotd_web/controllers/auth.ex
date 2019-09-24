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
  def login(conn, _params) do

    api_key = "ZHhFU2F2RmZUT2dFb1Jwd3ZRV0hVNHFSSDlKdnN6Ym8rQ0RZeUJmSXFlTHR5WjM3QkNFbVROa2l3Z25SWHprMC0tU3VPSG55dFROeDB3Tnd4UzIxczU4dz09--983492fbd087d4adc1c525975579767662e7a7b8"
    api_url_user = "https://api.nexusmods.com/v1/users/validate.json"

    case HTTPoison.get(api_url_user, [apikey: api_key, version: "0.1"]) do
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
