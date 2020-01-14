defmodule LotdWeb.SettingsLive do
  use Phoenix.LiveView, container: {:div, class: "container h-100"}
  import LotdWeb.LiveHelpers

  alias Lotd.{Accounts, Gallery}
  alias Lotd.Accounts.Character

  def render(assigns), do: LotdWeb.SettingsView.render("index.html", assigns)

  def mount(session, socket) do

    user = if session.user_id, do: Accounts.get_user!(session.user_id), else: nil

    socket = assign socket,
      changeset_new: Accounts.change_character(),
      characters: Accounts.list_characters(user),
      mods: Gallery.list_mods(),
      name_new: "",
      selected_character: user.active_character_id,
      user: user

    {:ok, socket}
  end

  def handle_event("show-character", %{"id" => id}, socket) do
    {:noreply, assign(socket, selected_character: String.to_integer(id))}
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

  def handle_event("create", %{"character" => character_params}, socket) do
    case Accounts.create_character(socket.assigns.user, character_params) do
      {:ok, character} ->
        {:noreply, assign(socket,
          changeset_new: Accounts.change_character(),
          characters: Accounts.list_characters(socket.assigns.user)
        )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset_new: changeset)}
    end
  end
end
