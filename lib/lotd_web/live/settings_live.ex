defmodule LotdWeb.SettingsLive do
  use Phoenix.LiveView, container: {:div, class: "container h-100"}

  alias Lotd.{Accounts, Gallery}

  def render(assigns), do: LotdWeb.SettingsView.render("index.html", assigns)

  def mount(session, socket) do

    user = if Map.has_key?(session, "user_id"),
      do: Accounts.get_user!(session["user_id"]), else: nil

    socket = assign socket,
      changeset: nil,
      characters: Accounts.list_characters(user),
      items: Gallery.list_items(),
      mods: Gallery.list_mods(),
      user: user

    {:ok, socket}
  end

  def handle_event("activate", %{"character" => %{"id" => id}}, socket) do
    case Accounts.get_character(id) do
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

  def handle_event("add-character", _params, socket) do
    changeset = Accounts.change_character(%{}) |> Map.put(:action, :insert)
    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("cancel", _params, socket), do:  {:noreply, assign(socket, :changeset, nil)}

  def handle_event("delete", %{"id" => id}, socket) do
    id = String.to_integer(id)

    if socket.assigns.user.active_character_id == id ||
      not Enum.member?(Enum.map( socket.assigns.characters, & &1.id), id) do
      {:noreply, socket}
    else
      socket.assigns.characters
      |> Enum.find(& &1.id == id)
      |> Accounts.delete_character()

      {:noreply, assign(socket,
        changeset: nil,
        characters: Accounts.list_characters(socket.assigns.user)
      )}
    end
  end

  def handle_event("edit-character", %{"id" => id}, socket) do
    character = Enum.find(socket.assigns.characters, & &1.id == String.to_integer(id))
    changeset = Accounts.change_character(character, %{}) |> Map.put(:action, :update)
    {:noreply, assign(socket, :changeset, changeset)}
  end


  def handle_event("create_character", %{"character" => character_params}, socket) do
    character_params = Map.put(character_params, "user_id", socket.assigns.user.id)
    case Accounts.create_character(character_params) do
      {:ok, _character} ->
        {:noreply, assign(socket,
          changeset: nil,
          characters: Accounts.list_characters(socket.assigns.user)
        )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("toggle", %{"id" => id}, socket) do

    character = Enum.find(socket.assigns.characters, & &1.id == socket.assigns.user.active_character_id)
    mod = Enum.find(socket.assigns.mods, & &1.id == String.to_integer(id))

    IO.inspect {Enum.map(character.mods, & &1.id), mod.id}

    if Enum.member?(Enum.map(character.mods, & &1.id), mod.id),
      do: Accounts.update_character_remove_mod(character, mod.id),
      else: Accounts.update_character_add_mod(character, mod)

    user = Accounts.get_user!(socket.assigns.user.id)

    {:noreply, assign(socket, characters: Accounts.list_characters(user), user: user)}
  end

  def handle_event("update_character", %{"character" => character_params}, socket) do
    case Accounts.update_character(socket.assigns.changeset.data, character_params) do
      {:ok, _character} ->
        {:noreply, assign(socket,
          changeset: nil,
          characters: Accounts.list_characters(socket.assigns.user)
        )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("validate", %{"character" => params}, socket) do
    changeset =
      socket.assigns.changeset.data
      |> Accounts.change_character(params)
      |> Map.put(:action, socket.assigns.changeset.action)

    {:noreply, assign(socket, :changeset, changeset)}
  end
end
