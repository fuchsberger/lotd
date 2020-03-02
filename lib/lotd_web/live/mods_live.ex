defmodule LotdWeb.ModsLive do

  use Phoenix.LiveView, container: {:div, class: "container"}

  import LotdWeb.LiveHelpers
  alias Lotd.Gallery
  alias Lotd.Gallery.Mod

  def render(assigns), do: LotdWeb.ManageView.render("mods.html", assigns)

  def mount(_params, _session, socket) do
    {:ok, assign(socket,
      changeset: Gallery.change_mod(%Mod{}),
      mods: Gallery.list_mods()
    )}
  end

  def handle_event("validate", %{"mod" => params}, socket) do
    {:noreply, assign(socket, changeset: Mod.changeset(socket.assigns.changeset.data, params))}
  end

  def handle_event("save", _params, socket) do
    case Lotd.Repo.insert_or_update(socket.assigns.changeset) do
      {:ok, mod } ->
        mod = Lotd.Repo.preload(mod, :items)
        {:noreply, assign(socket,
          changeset: Gallery.change_mod(%Mod{}),
          mods: update_collection(socket.assigns.mods, mod)
        )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("edit", %{"id" => id}, socket) do
    id = String.to_integer(id)
    if socket.assigns.changeset.data.id == id do
      {:noreply, assign(socket, changeset: Gallery.change_mod(%Mod{}))}
    else
      mod = Enum.find(socket.assigns.mods, & &1.id == id)
      {:noreply, assign(socket, changeset: Gallery.change_mod(mod))}
    end
  end

  def handle_event("delete", _params, socket) do
    mod = Enum.find(socket.assigns.mods, & &1.id == socket.assigns.changeset.data.id)
    case Gallery.delete_mod(mod) do
      {:ok, mod} ->
        {:noreply, assign(socket,
          changeset: Gallery.change_mod(%Mod{}),
          mods: Enum.reject(socket.assigns.mods, & &1.id == mod.id)
        )}

      {:error, _reason} ->
        {:noreply, socket}
    end
  end
end
