defmodule LotdWeb.ModalComponent do
  use Phoenix.LiveComponent

  use Phoenix.HTML

  import Phoenix.HTML.Form, except: [select: 4, text_input: 3, url_input: 3]
  import LotdWeb.ErrorHelpers
  import LotdWeb.ViewHelpers
  import LotdWeb.GalleryView

  alias Lotd.Gallery
  alias Lotd.Gallery.{Display, Item, Location, Mod, Region, Room}

  def render(assigns) do
    ~L"""
    <div id="modal">
    <%= unless is_nil(@changeset) do %>
      <div class="modal show d-block" tabindex="-1" role="dialog">
        <%= f = form_for @changeset, "#", [
          class: "modal-dialog#{if @changeset.action, do: " was-validated"}",
          novalidate: true,
          phx_change: :validate,
          phx_submit: :save,
          phx_target: "#modal"
        ] %>
          <div class="modal-content">
            <div class="modal-header">
              <h5 class="modal-title">Add / Edit <%= title(@changeset.data) %></h5>
              <button type="button" class="close" phx-click="close" phx-target="#modal">
                <span aria-hidden="true">&times;</span>
              </button>
            </div>
            <div class="modal-body">
              <%= if @changeset.action do %>
                <div class="alert alert-danger">
                  Oops, something went wrong! Please check errors below.
                </div>
              <% end %>
              <div class='form-group'>
                <%= label f, :name %>
                <%= text_input f, :name, class: control_class(f, :name), placeholder: "Name" %>
                <%= error_tag f, :name %>
              </div>
              <div class='form-group'>
                <%= label f, :url %>
                <%= url_input f, :url, class: control_class(f, :url), placeholder: "Url" %>
                <%= error_tag f, :url %>
              </div>
              <%= if Enum.member?(["display", "item"], struct_name(@changeset.data)) do %>
                <div class='form-group'>
                  <%= label f, :room_id, "Room" %>
                  <%= select f, :room_id, select_options(@rooms), class: "form-control" %>
                  <%= error_tag f, :room_id %>
                </div>
              <% end %>
              <%= if struct_name(@changeset.data) == "item" do %>
                <div class='form-group'>
                  <%= label f, :display_id, "Display" %>
                  <%= select f, :display_id, display_options(@changeset, @displays), class: "form-control" %>
                  <%= error_tag f, :display_id %>
                </div>
                <div class='form-group'>
                  <%= label f, :location_id, "Location" %>
                  <%= select f, :location_id, select_options(@locations), class: "form-control" %>
                  <%= error_tag f, :location_id %>
                </div>
                <div class='form-group'>
                  <%= label f, :mod_id, "Mod" %>
                  <%= select f, :mod_id, select_options(@mods), class: "form-control" %>
                  <%= error_tag f, :mod_id %>
                </div>
              <% end %>
            </div>
            <div class="modal-footer">
              <%= unless is_nil(@changeset.data.id) do %>
                <button
                  class="btn btn-danger"
                  data-confirm="Are you sure you want to delete? This is irreversible and can do serious damage to the database."
                  type='button'
                  phx-click="delete"
                >
                  Delete
                </button>
              <% end %>
              <%= submit "Save", class: "btn btn-primary" %>
            </div>
          </div>
        </form>
      </div>
      <div class="modal-backdrop show"></div>
    <% end %>
    </div>
    """
  end

  def mount(socket), do: {:ok, assign(socket, changeset: nil)}

  def handle_event("close", _params, socket), do: {:noreply, assign(socket, changeset: nil)}

  def handle_event("validate", params, socket) do
    changeset = case socket.assigns.changeset.data do
      %Item{} -> Item.changeset(socket.assigns.changeset.data, params["item"])
      %Room{} -> Room.changeset(socket.assigns.changeset.data, params["room"])
      %Display{} -> Display.changeset(socket.assigns.changeset.data, params["display"])
      %Region{} -> Region.changeset(socket.assigns.changeset.data, params["region"])
      %Location{} -> Location.changeset(socket.assigns.changeset.data, params["location"])
      %Mod{} -> Mod.changeset(socket.assigns.changeset.data, params["mod"])
    end
    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", _params, socket) do
    case Lotd.Repo.insert_or_update(socket.assigns.changeset) do
      {:ok, object } ->
        send self(), {:update_data, object}
        {:noreply, assign(socket, changeset: nil)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("delete", _params, socket) do
    id =  socket.assigns.changeset.data.id
    case socket.assigns.changeset.data do
      %Display{} ->
        display = Enum.find(socket.assigns.displays, & &1.id == id)
        case Gallery.delete_display(display) do
          {:ok, _display} ->
            {:noreply, assign(socket, changeset: nil, displays: Gallery.list_displays())}

          {:error, _reason} ->
            {:noreply, socket}
        end

      %Item{} ->
        item = Enum.find(socket.assigns.items, & &1.id == id)
        case Gallery.delete_item(item) do
          {:ok, _item} ->
            {:noreply, assign(socket, changeset: nil, items: Gallery.list_items())}

          {:error, _reason} ->
            {:noreply, socket}
        end

      %Location{} ->
        location = Enum.find(socket.assigns.locations, & &1.id == id)
        case Gallery.delete_location(location) do
          {:ok, _location} ->
            {:noreply, assign(socket, changeset: nil, locations: Gallery.list_locations())}

          {:error, _reason} ->
            {:noreply, socket}
        end

      %Mod{} ->
        mod = Enum.find(socket.assigns.mods, & &1.id == id)
        case Gallery.delete_mod(mod) do
          {:ok, _mod} ->
            {:noreply, assign(socket, changeset: nil, mods: Gallery.list_mods())}

          {:error, _reason} ->
            {:noreply, socket}
        end

      %Region{} ->
        region = Enum.find(socket.assigns.regions, & &1.id == id)
        case Gallery.delete_room(region) do
          {:ok, _room} ->
            {:noreply, assign(socket, changeset: nil, rooms: Gallery.list_regions())}

          {:error, _reason} ->
            {:noreply, socket}
        end

      %Room{} ->
        room = Enum.find(socket.assigns.rooms, & &1.id == id)
        case Gallery.delete_room(room) do
          {:ok, _room} ->
            {:noreply, assign(socket, changeset: nil, rooms: Gallery.list_rooms())}

          {:error, _reason} ->
            {:noreply, socket}
        end
    end
  end
end
