defmodule LotdWeb.CharactersLive do
  use Phoenix.LiveView, container: {:div, class: "container"}

  import LotdWeb.LiveHelpers
  alias Lotd.{Accounts, Gallery, Repo}
  alias Lotd.Accounts.Character

  def render(assigns), do: LotdWeb.ManageView.render("characters.html", assigns)

  def mount(_params, %{"user_id" => user_id}, socket) do

    user = Accounts.get_user!(user_id)

    socket = assign socket,
      changeset: Accounts.change_character(%Character{}),
      characters: Accounts.list_characters(user),
      items: Gallery.list_items(),
      mods: Gallery.list_mods(),
      user: user

    {:ok, socket}
  end

  def handle_event("select", %{"id" => id}, socket) do
    id = String.to_integer(id)
    if socket.assigns.changeset.data.id == id do
      {:noreply, assign(socket, changeset: Accounts.change_character(%Character{}))}
    else
      character = Enum.find(socket.assigns.characters, & &1.id == id)
      {:noreply, assign(socket, changeset: Accounts.change_character(character))}
    end
  end

  def handle_event("activate", _params, socket) do
    character = Enum.find(socket.assigns.characters, & &1.id == socket.assigns.changeset.data.id)

    if character.user_id == socket.assigns.user.id do # <-- hacker safety measure
      case Accounts.update_user(socket.assigns.user, %{active_character_id: character.id}) do
        {:ok, user} ->
          {:noreply, assign(socket,
            changeset: Accounts.change_character(%Character{}),
            user: Repo.preload(user, active_character: [:items, :mods])
          )}
      end
    else
      {:noreply, socket}
    end
  end

  def handle_event("validate", %{"character" => params}, socket) do
    {:noreply, assign(socket,
      changeset: Character.changeset(socket.assigns.changeset.data, params))}
  end

  def handle_event("save", _params, socket) do
    case Lotd.Repo.insert_or_update(socket.assigns.changeset) do
      {:ok, character } ->
        character = Repo.preload(character, [:items, :mods])
        {:noreply, assign(socket,
          changeset: Accounts.change_character(%Character{}),
          characters: update_collection(socket.assigns.characters, character)
        )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("delete", _params, socket) do
    character = Enum.find(socket.assigns.characters, & &1.id == socket.assigns.changeset.data.id)
    case Accounts.delete_character(character) do
      {:ok, character} ->
        {:noreply, assign(socket,
          changeset: Accounts.change_character(%Character{}),
          characters: Enum.reject(socket.assigns.characters, & &1.id == character.id)
        )}

      {:error, _reason} ->
        {:noreply, socket}
    end
  end

  def handle_event("toggle", %{"id" => id}, socket) do
    character = socket.assigns.changeset.data
    mod = Enum.find(socket.assigns.mods, & &1.id == String.to_integer(id))

    character = if Enum.member?(Enum.map(character.mods, & &1.id), mod.id),
      do: Accounts.update_character_remove_mod(character, mod.id),
      else: Accounts.update_character_add_mod(character, mod)

    character = Repo.preload(character, [:mods, :items], force: true)
    user = Accounts.get_user!(socket.assigns.user.id)

    {:noreply, assign(socket,
      changeset: Accounts.change_character(character),
      characters: update_collection(socket.assigns.characters, character),
      user: user
    )}
  end
end
