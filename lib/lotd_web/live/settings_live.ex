defmodule LotdWeb.SettingsLive do
  use Phoenix.LiveView, container: {:div, class: "container h-100"}

  alias Lotd.Repo
  alias Lotd.{Accounts, Gallery}
  alias Lotd.Accounts.Character

  def render(assigns), do: LotdWeb.SettingsView.render("index.html", assigns)

  def mount(session, socket) do

    user = if Map.has_key?(session, "user_id"),
      do: Accounts.get_user!(session["user_id"]), else: nil

    socket = assign socket,
      changeset_new: Accounts.change_character(),
      changeset_rename: Accounts.change_character(user.active_character),
      characters: Accounts.list_characters(user),
      mods: Gallery.list_mods(),
      selected_character: user.active_character_id,
      user: user

    {:ok, socket}
  end

  def handle_event("show-character", %{"id" => id}, socket) do
    character = Enum.find(socket.assigns.characters, & &1.id == String.to_integer(id))
    {:noreply, assign(socket,
      changeset_rename: Accounts.change_character(character),
      selected_character: character.id
    )}
  end

  def handle_event("activate", %{"id" => id}, socket) do
    case Accounts.get_character!(id) do
      nil -> {:noreply, socket}
      character ->
        if character.user_id == socket.assigns.user.id do # <-- hacker safety measure
          Accounts.activate_character(socket.assigns.user, character.id)
          {:noreply, assign(socket, user: Accounts.get_user!(socket.assigns.user.id))}
        else
          {:noreply, socket}
        end
    end
  end

  def handle_event("delete", _params, socket) do
    id = socket.assigns.selected_character
    if socket.assigns.user.active_character_id == id do
      {:noreply, socket}
    else
      socket.assigns.characters
      |> Enum.find(& &1.id == id)
      |> Accounts.delete_character()

      {:noreply, assign(socket,
        selected_character: socket.assigns.user.active_character_id,
        changeset_rename: Accounts.change_character(socket.assigns.user.active_character),
        characters: Enum.reject(socket.assigns.characters, & &1.id == id)
      )}
    end
  end

  def handle_event("toggle", %{"id" => id}, socket) do
    mod_id = String.to_integer(id)
    character = Enum.find(socket.assigns.characters, & &1.id == socket.assigns.selected_character)
    mod = Enum.find(socket.assigns.mods, & &1.id == mod_id)

    character = unless is_nil(Enum.find(character.mods, & &1.id == mod_id)),
      do: Accounts.update_character_remove_mod(character, mod.id),
      else: Accounts.update_character_add_mod(character, mod)

    index = Enum.find_index(socket.assigns.characters, & &1.id == character.id)

    characters = List.replace_at(socket.assigns.characters, index, character)

    {:noreply, assign(socket, characters: characters )}
  end

  def handle_event("validate_new", %{"character" => params}, socket) do
    changeset =
      %Character{}
      |> Accounts.change_character(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset_new: changeset)}
  end

  def handle_event("validate_rename", %{"character" => params}, socket) do
    changeset =
      %Character{}
      |> Accounts.change_character(params)
      |> Map.put(:action, :update)

    {:noreply, assign(socket, changeset_rename: changeset)}
  end

  def handle_event("create", %{"character" => character_params}, socket) do
    case Accounts.create_character(socket.assigns.user, character_params) do
      {:ok, character} ->
        {:noreply, assign(socket,
          changeset_new: Accounts.change_character(),
          characters: [ Repo.preload(character, [:items, :mods]) | socket.assigns.characters]
        )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset_new: changeset)}
    end
  end

  def handle_event("update", %{"character" => character_params}, socket) do
    idx = Enum.find_index(socket.assigns.characters, & &1.id == socket.assigns.selected_character)

    case Accounts.update_character(Enum.at(socket.assigns.characters, idx), character_params) do
      {:ok, character} ->

        character = Repo.preload(character, [:items, :mods])

        {:noreply, assign(socket,
          changeset_rename: Accounts.change_character(character),
          characters: List.replace_at(socket.assigns.characters, idx,character)
        )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset_rename: changeset)}
    end
  end
end
