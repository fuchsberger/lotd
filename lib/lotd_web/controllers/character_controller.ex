defmodule LotdWeb.CharacterController do
  use LotdWeb, :controller

  alias Lotd.Accounts
  alias Lotd.Accounts.{Character, User}

  action_fallback LotdWeb.ErrorController

  def index(conn, _params) do
    characters = Accounts.list_user_characters(conn.assigns.current_user)
    render conn, "index.html", action: nil, characters: characters
  end

  def new(conn, _params) do
    characters = Accounts.list_user_characters(conn.assigns.current_user)

    if Enum.count(characters) < 10 do
      changeset = Accounts.change_character(%Character{})
      render(conn, "index.html", action: :create, changeset: changeset, characters: characters)
    else
      conn
      |> put_flash(:error, gettext("You cannot create more than 10 characters."))
      |> redirect(to: Routes.character_path(conn, :index))
    end
  end

  def create(conn, %{"character" => character_params}) do
    characters = Accounts.list_user_characters(conn.assigns.current_user)

    if Enum.count(characters) < 10 do
      case Accounts.create_character(conn.assigns.current_user, character_params) do
        {:ok, _character} ->
          conn
          |> put_flash(:info, "Character created successfully.")
          |> redirect(to: Routes.character_path(conn, :index))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "index.html", action: :create, changeset: changeset, characters: characters)
      end
    else
      conn
      |> put_flash(:error, gettext("You cannot create more than 10 characters."))
      |> redirect(to: Routes.character_path(conn, :index))
    end
  end

  def edit(conn, %{"id" => id}) do
    with characters <- Accounts.list_user_characters(conn.assigns.current_user),
        %Character{} = character <- Accounts.get_character!(id),
        :ok <- owned?(conn.assigns.current_user, character) do
      changeset = Accounts.change_character(character)
      render(conn, "index.html", action: :update, changeset: changeset, characters: characters)
    end
  end

  def update(conn, %{"id" => id, "character" => character_params}) do
    with characters <- Accounts.list_user_characters(conn.assigns.current_user),
        %Character{} = character <- Accounts.get_character!(id),
        :ok <- owned?(conn.assigns.current_user, character) do
      case Accounts.update_character(character, character_params) do
        {:ok, _character} ->
          conn
          |> put_flash(:info, "Character updated successfully.")
          |> redirect(to: Routes.character_path(conn, :index))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "index.html", action: :update, changeset: changeset, characters: characters)
      end
    end
  end

  def remove(conn, %{"id" => id}) do
    with characters <- Accounts.list_user_characters(conn.assigns.current_user),
        %Character{} = character <- Accounts.get_character!(id),
        :ok <- owned?(conn.assigns.current_user, character) do
      render(conn, "index.html", action: :delete, character: character, characters: characters)
    end
  end

  def delete(conn, %{"id" => id}) do
    with %Character{} = character <- Accounts.get_character!(id),
        :ok <- owned?(conn.assigns.current_user, character),
        {:ok, _character} = Accounts.delete_character(character)
    do
      conn
      |> put_flash(:info, "Character deleted successfully.")
      |> redirect(to: Routes.character_path(conn, :index))
    end
  end

  def activate(conn, %{"id" => id}) do
    with %Character{} = character <- Accounts.get_character!(id),
    :ok <- owned?(conn.assigns.current_user, character) do
      case Accounts.update_user(conn.assigns.current_user, %{active_character_id: id}) do
        {:ok, _character} ->
          redirect(conn, to: Routes.character_path(conn, :index))

        {:error, %Ecto.Changeset{} = changeset} ->
          conn
          |> put_flash(:error, gettext("Character could not be activated."))
          |> render("edit.html", action: :index, character: character, changeset: changeset)
      end
    end
  end

  def toggle(conn, %{"item_id" => id}) do
    collected = Accounts.toggle_item!(conn.assigns.current_user.active_character, id)

    conn
    |> put_status(200)
    |> json(%{collected: collected})
  end

  defp owned?(%User{} = user, %Character{} = character) do
    if character.user_id == user.id, do: :ok, else: {:error, :forbidden}
  end
end
