defmodule LotdWeb.SessionController do
  use LotdWeb, :controller

  alias Lotd.{Accounts, Gallery}
  alias LotdWeb.Auth

  @doc """
  connect to nexus to test api key and return username and userid.
  Checks if ok check if user_id already in database
    if not, create user, login and send session token back to client
    if yes, login and send session token back to client
  """
  def create(conn, %{"session" => session}) do

    url = Application.get_env(:lotd, Lotd.NexusAPI)[:user_url]
    header =
      Application.get_env(:lotd, Lotd.NexusAPI)[:header]
      |> Keyword.put(:apikey, session["api_key"])

    case HTTPoison.get(url, header) do
      {:ok, response} ->
        # response contains nexus user information such as userid and name
        response = Jason.decode!(response.body)
        id = response["user_id"]
        name = response["name"]

        case Accounts.get_user(id) do
          # no record found --> create it and authenticate
          nil ->
            case Accounts.register_user(%{id: id, name: name}) do
              {:ok, user} ->

                # also create a default character
                {:ok, character} = Accounts.create_character(user, %{name: "Default"})

                # activate character and enable lotd mod
                Accounts.update_user(user, %{ active_character_id: character.id})
                Accounts.update_character_add_mod(character, Gallery.get_mod!(1))

                # login and redirect to item page
                conn
                |> Auth.login(user)
                |> redirect(to: Routes.gallery_path(conn, :index))

              {:error, _changeset} ->
                conn
                |> put_flash(:error, "Error: Could not create user in database!")
                |> redirect(to: Routes.gallery_path(conn, :index))
                |> halt()
            end
          # user found --> authenticate
          user ->
            conn
            |> Auth.login(user)
            |> redirect(to: Routes.gallery_path(conn, :index))
            |> halt()
        end

      {:error, %HTTPoison.Error{reason: reason}} ->
        conn
        |> put_flash(:error, "Error connecting to Nexus. #{reason}")
        |> redirect(to: Routes.gallery_path(conn, :index))
        |> halt()
    end
  end

  def delete(conn, _) do
    conn
    |> Auth.logout()
    |> redirect(to: Routes.gallery_path(conn, :index))
    |> halt()
  end
end
