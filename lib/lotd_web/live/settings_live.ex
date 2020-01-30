defmodule LotdWeb.SettingsLive do
  use Phoenix.LiveView, container: {:div, class: "container h-100"}

  alias Lotd.{Accounts, Gallery}
  alias Lotd.Accounts.Character

  def render(assigns), do: LotdWeb.SettingsView.render("index.html", assigns)

  def mount(_params, session, socket) do

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

  def handle_event("add", _params, socket) do
    changeset = Accounts.change_character(%Character{})
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

  def handle_event("edit", %{"id" => id}, socket) do
    character = Enum.find(socket.assigns.characters, & &1.id == String.to_integer(id))
    changeset = Accounts.change_character(character)
    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("toggle", %{"id" => id}, socket) do

    character = Enum.find(socket.assigns.characters, & &1.id == socket.assigns.user.active_character_id)
    mod = Enum.find(socket.assigns.mods, & &1.id == String.to_integer(id))

    if Enum.member?(Enum.map(character.mods, & &1.id), mod.id),
      do: Accounts.update_character_remove_mod(character, mod.id),
      else: Accounts.update_character_add_mod(character, mod)

    user = Accounts.get_user!(socket.assigns.user.id)

    {:noreply, assign(socket, characters: Accounts.list_characters(user), user: user)}
  end

  def handle_event("save", _params, socket) do
    case Lotd.Repo.insert_or_update(socket.assigns.changeset) do
      {:ok, character} ->
        character = Lotd.Repo.preload(character, [:mods, :items])

        characters =
          socket.assigns.characters
          |> Enum.reject(& &1.id == character.id)
          |> List.insert_at(0, character)
          |> Enum.sort_by(&(&1.name))
        {:noreply, assign(socket, changeset: nil, characters: characters)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("validate", %{"character" => params}, socket) do
    changeset =
      socket.assigns.changeset.data
      |> Character.changeset(params)
      |> Ecto.Changeset.put_assoc(:user, socket.assigns.user)
    {:noreply, assign(socket, :changeset, changeset)}
  end
end
