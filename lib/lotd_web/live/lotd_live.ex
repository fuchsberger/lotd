defmodule LotdWeb.LotdLive do

  use LotdWeb, :live_view

  alias Lotd.{Accounts, Gallery, Repo}
  alias Lotd.Accounts.Character
  alias Lotd.Gallery.{Item, Display, Location, Mod, Room, Region}

  @requires_character ~w(update_character)a
  @requires_moderator ~w(create_display update_display create_location update_location create_mod update_mod)a
  @requires_admin ~w(users)a
  @private_routes [:create_character] ++ @requires_character ++ @requires_moderator ++ @requires_admin

  def broadcast(topic, message), do: Phoenix.PubSub.broadcast(Lotd.PubSub, topic, message)

  def mount(_params, session, socket) do
    user =
      case Map.get(session, "user_token") do
        nil ->
          nil

        token ->
          user =
            token
            |> Accounts.get_user_by_session_token
            |> Accounts.preload_user_associations

          Phoenix.PubSub.subscribe(Lotd.PubSub, "user-id:#{user.id}")
          user
      end

    {:ok, socket
    |> assign(:search_changeset, search_changeset(%{}))
    |> assign(:character, nil)
    |> assign(:displays, Gallery.list_displays)
    |> assign(:filter, nil)
    |> assign(:items, Gallery.list_items)
    |> assign(:location_id, nil)
    |> assign(:locations, Gallery.list_locations)
    |> assign(:mod_id, 1)
    |> assign(:mods, Gallery.list_mods)
    |> assign(:display_id, nil)
    |> assign(:region_id, 1)
    |> assign(:regions, Gallery.list_regions)
    |> assign(:room_id, 1)
    |> assign(:rooms, Gallery.list_rooms)
    |> assign(:search, "")
    |> assign(:user, user)
    |> assign_displays
    |> assign_locations
    |> assign_items}
  end

  defp assign_displays(socket) do
    search_query = Ecto.Changeset.get_field(socket.assigns.search_changeset, :query)

    displays =
      if search_query do
        socket.assigns.displays
        |> Enum.map(& Map.put(&1, :similarity, FuzzyCompare.similarity(&1.name, search_query)))
        |> Enum.sort_by(& &1.similarity, :desc)
        |> Enum.filter(& &1.similarity > 0.9)
        |> Enum.take(50)
      else
        Enum.filter(socket.assigns.displays, & &1.room_id == socket.assigns.room_id)
      end
      |> Enum.map(fn %{id: id} = display ->
          count = Enum.count(Enum.filter(socket.assigns.items, & &1.display_id == id))
          Map.put(display, :count, count)
        end)

    socket
    |> assign(:current_displays, displays)
    |> assign(:current_room_display_count, displays |> Enum.map(& &1.count) |> Enum.sum())
  end

  defp assign_locations(socket) do
    search_query = Ecto.Changeset.get_field(socket.assigns.search_changeset, :query)

    locations =
      if search_query do
        socket.assigns.locations
        |> Enum.map(& Map.put(&1, :similarity, FuzzyCompare.similarity(&1.name, search_query)))
        |> Enum.sort_by(& &1.similarity, :desc)
        |> Enum.filter(& &1.similarity > 0.9)
        |> Enum.take(50)
      else
        Enum.filter(socket.assigns.locations, & &1.region_id == socket.assigns.region_id)
      end
      |> Enum.map(fn %{id: id} = location ->
          count = Enum.count(Enum.filter(socket.assigns.items, & &1.location_id == id))
          Map.put(location, :count, count)
        end)

    socket
    |> assign(:current_locations, locations)
    |> assign(:current_region_location_count, locations |> Enum.map(& &1.count) |> Enum.sum())
  end

  defp assign_items(socket) do
    search_query = Ecto.Changeset.get_field(socket.assigns.search_changeset, :query)

    current_items =
      if search_query do
        socket.assigns.items
        |> Enum.map(& Map.put(&1, :similarity, FuzzyCompare.ChunkSet.standard_similarity(&1.name, search_query)))
        |> Enum.sort_by(& &1.similarity, :desc)
        |> Enum.take(50)
      else
        case socket.assigns.live_action do
          :gallery ->
            case socket.assigns.display_id do
              nil ->
                ids = Enum.map(socket.assigns.current_displays, & &1.id)
                Enum.filter(socket.assigns.items, & &1.display_id in ids)

              id ->
                Enum.filter(socket.assigns.items, & &1.display_id == id)
            end
          :locations ->
            case socket.assigns.region_id do
              nil ->
                ids = Enum.map(socket.assigns.current_locations, & &1.id)
                Enum.filter(socket.assigns.items, & &1.location_id in ids)

              id ->
                Enum.filter(socket.assigns.items, & &1.location_id == id)
            end
          :mods ->
            Enum.filter(socket.assigns.items, & &1.mod_id == socket.assigns.mod_id)

          _ ->
            []
        end
      end

    assign(socket, :current_items, Enum.take(current_items, 200))
  end

  def handle_params(_unsigned_params, uri, socket) do
    cond do
      # ensure user is authenticated if required to
      socket.assigns.live_action in @private_routes && is_nil(socket.assigns.user) ->
        {:noreply, socket
        |> put_flash(:error, gettext "You must login to access this page.")
        |> push_patch(to: Routes.lotd_path(socket, :gallery))}

      # ensure user has character if required to
      socket.assigns.live_action in @requires_character && is_nil(socket.assigns.user.active_character) ->
        {:noreply, socket
        |> put_flash(:error, gettext "Activated character needed to access.")
        |> push_patch(to: Routes.lotd_path(socket, :mods))}

      # ensure user is moderator if required to
      socket.assigns.live_action in @requires_moderator && !socket.assigns.user.moderator ->
        {:noreply, socket
        |> put_flash(:error, gettext "Moderator access needed for this page.")
        |> push_patch(to: Routes.lotd_path(socket, :gallery))}

      # ensure user is admin if required to
      socket.assigns.live_action in @requires_admin && !socket.assigns.user.admin ->
        {:noreply, socket
        |> put_flash(:error, gettext "Admin access needed for this page.")
        |> push_patch(to: Routes.lotd_path(socket, :gallery))}

      # redirect from index page
      socket.assigns.live_action == :index ->
        {:noreply, push_patch(socket, to: Routes.lotd_path(socket, :gallery))}

      # invalid url -> redirect to gallery
      socket.assigns.live_action == :unknown_url ->
        {:noreply, socket
        |> put_flash(:error, uri <> gettext(" doesn't exist."))
        |> push_patch(to: Routes.lotd_path(socket, :gallery))}

      true ->
        {:noreply, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <div>
      <.flash flash={@flash} />
      <%= case @live_action do %>
        <% :about -> %>
          <%= Phoenix.View.render(LotdWeb.PageView, "about.html", []) %>

        <% :create_character -> %>
          <.live_component
            action={:create}
            mods={@mods}
            user={@user}
            id="create-character-component"
            module={LotdWeb.Live.CharacterComponent}
          />

        <% :update_character -> %>
          <.live_component
            action={:update}
            mods={@mods}
            user={@user}
            id="update-character-component"
            module={LotdWeb.Live.CharacterComponent}
          />

        <% :create_display -> %>
          <.live_component
            display_id={nil}
            id="create-display-component"
            items={[]}
            module={LotdWeb.Live.DisplayComponent}
          />

        <% :update_display -> %>
          <.live_component
            display_id={@display_id}
            items={@current_items}
            id="update-display-component"
            module={LotdWeb.Live.DisplayComponent}
          />

        <% :create_location -> %>
          <.live_component
            location_id={nil}
            id="create-location-component"
            items={[]}
            module={LotdWeb.Live.LocationComponent}
          />

        <% :update_location -> %>
          <.live_component
            location_id={@location_id}
            items={@current_items}
            id="update-location-component"
            module={LotdWeb.Live.LocationComponent}
          />

        <% :create_mod -> %>
          <.live_component
            mod_id={nil}
            id="create-mod-component"
            items={[]}
            module={LotdWeb.Live.ModComponent}
          />

        <% :update_mod -> %>
          <.live_component
            mod_id={@mod_id}
            items={@current_items}
            id="update-mod-component"
            module={LotdWeb.Live.ModComponent}
          />

        <% _ -> %>
          <.live_component
            items={@current_items}
            id="items-component"
            module={LotdWeb.Live.ItemsComponent}
            user={@user}
          />
      <% end %>
    </div>
    """
  end

  defp search_changeset(params) do
    {%{}, %{query: :string}}
    |> Ecto.Changeset.cast(params, [:query])
    |> Ecto.Changeset.validate_length(:query, max: 80)
  end

  defp active_character(socket), do: socket.assigns.user && Enum.find(socket.assigns.user.characters, & &1.id == socket.assigns.user.active_character_id)

  def handle_event("add", %{"type" => type}, socket) do
    if is_nil(socket.assigns.changeset) do
      case type do
        "item" ->
          {:noreply, socket
          |> assign(:changeset, Gallery.change_item(%Item{}, %{}))
          |> assign(:display_options, Gallery.list_display_options())
          |> assign(:location_options, Gallery.list_location_options())}

        "character" ->
          {:noreply, assign(socket, :changeset, Accounts.change_character(%Character{}))}

        "display" ->
          {:noreply, socket
          |> assign(:changeset, Gallery.change_display(%Display{}))
          |> assign(:room_options, Gallery.list_room_options())}

        "room" ->
          {:noreply, assign(socket, :changeset, Gallery.change_room(%Room{}))}

        "location" ->
          {:noreply, socket
          |> assign(:changeset, Gallery.change_location(%Location{}))
          |> assign(:region_option, Gallery.list_region_options())}

        "region" ->
          {:noreply, assign(socket, :changeset, Gallery.change_region(%Region{}))}

        "mod" ->
          {:noreply, assign(socket, :changeset, Gallery.change_mod(%Mod{}))}
      end
    else
      {:noreply, assign(socket, :changeset, nil)}
    end
  end

  def handle_event("activate", %{"character" => id}, socket) do
    case Accounts.update_user(socket.assigns.user, %{active_character_id: id}) do
      {:ok, _user} ->
        user = Accounts.get_user!(socket.assigns.user.id)

        {:noreply, socket
        |> assign(:items, Gallery.list_items(user))
        |> assign(:user, user)}

      {:error, _reason} ->
        {:noreply, socket}
    end
  end

  def handle_event("activate", %{"mod" => id}, socket) do
    case Accounts.activate_mod(active_character(socket), Gallery.get_mod!(id)) do
      {:ok, _character} ->
        user = Accounts.get_user!(socket.assigns.user.id)

        {:noreply, socket
        |> assign(:items, Gallery.list_items(user))
        |> assign(:user, user)}

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  def handle_event("deactivate", %{"mod" => id}, socket) do
    case Accounts.deactivate_mod(active_character(socket), Gallery.get_mod!(id)) do
      {:ok, _character} ->
        user = Accounts.get_user!(socket.assigns.user.id)

        {:noreply, socket
        |> assign(:items, Gallery.list_items(user))
        |> assign(:user, user)}

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  def handle_event("clear", %{"filter" => _}, socket) do
    {:noreply, assign(socket, :filter, nil)}
  end

  def handle_event("clear", %{"search" => _}, socket) do
    {:noreply, assign(socket, :search, "")}
  end

  def handle_event("filter", %{"region" => id}, socket) do

    changeset = if socket.assigns.changeset && Map.has_key?(socket.assigns.changeset.data, :region_id) do
      region = Gallery.get_region!(String.to_integer(id))
      Ecto.Changeset.change(socket.assigns.changeset, %{
        region_id: region.id,
        region_name: region.name
      })
    else socket.assigns.changeset end

    {:noreply, socket
    |> assign(:changeset, changeset)
    |> assign(:filter, {:region, String.to_integer(id)})
    |> assign(:search, "")
    |> assign(:tab, 2)}
  end

  def handle_event("filter", %{"room" => id}, socket) do

    changeset = if socket.assigns.changeset && Map.has_key?(socket.assigns.changeset.data, :room_id) do
      room = Gallery.get_room!(String.to_integer(id))
      Ecto.Changeset.change(socket.assigns.changeset, %{room_id: room.id, room_name: room.name})
    else
      socket.assigns.changeset
    end

    {:noreply, socket
    |> assign(:changeset, changeset)
    |> assign(:filter, {:room, String.to_integer(id)})
    |> assign(:search, "")
    |> assign(:tab, 1)}
  end

  def handle_event("filter", %{"location" => id}, socket) do
    changeset = if socket.assigns.changeset && Map.has_key?(socket.assigns.changeset.data, :location_id) do
      location = Gallery.get_location!(String.to_integer(id))
      Ecto.Changeset.change(socket.assigns.changeset, %{
        location_id: location.id,
        location_name: location.name
      })
    else
      socket.assigns.changeset
    end

    {:noreply, socket
    |> assign(:changeset, changeset)
    |> assign(:filter, {:location, String.to_integer(id)})
    |> assign(:search, "")
    |> assign(:tab, 2)}
  end

  def handle_event("filter", %{"display" => id}, socket) do
    changeset = if socket.assigns.changeset && Map.has_key?(socket.assigns.changeset.data, :display_id) do
      display = Gallery.get_display!(String.to_integer(id))
      Ecto.Changeset.change(socket.assigns.changeset, %{
        display_id: display.id,
        display_name: display.name
      })
    else
      socket.assigns.changeset
    end

    {:noreply, socket
    |> assign(:changeset, changeset)
    |> assign(:filter, {:display, String.to_integer(id)})
    |> assign(:search, "")
    |> assign(:tab, 1)}
  end

  def handle_event("filter", %{"mod" => id}, socket) do

    changeset = if socket.assigns.changeset && Map.has_key?(socket.assigns.changeset.data, :mod_id) do
      mod = Gallery.get_mod!(String.to_integer(id))
      Ecto.Changeset.change(socket.assigns.changeset, %{mod_id: mod.id, mod_name: mod.name})
    else
      socket.assigns.changeset
    end

    {:noreply, socket
    |> assign(:changeset, changeset)
    |> assign(:filter, {:mod, String.to_integer(id)})
    |> assign(:search, "")
    |> assign(:tab, 3)}
  end

  def handle_event("search", %{"search" => params}, socket) do
    {:noreply, socket
    |> assign(:search_changeset, search_changeset(params))
    |> assign_displays
    |> assign_items}
  end

  def handle_event("tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, :tab, String.to_integer(tab))}
  end

  def handle_event("toggle", %{"item" => id}, socket) do
    character = active_character(socket)
    item = Enum.find(socket.assigns.items, & &1.id == String.to_integer(id))

    if Enum.member?(character.items, item.id),
      do: Accounts.remove_item(character, item),
      else: Accounts.collect_item(character, item)

    {:noreply, assign(socket, :user, Accounts.get_user!(socket.assigns.user.id))}
  end

  def handle_event("toggle", %{"hide" => _}, socket) do
    case Accounts.update_user(socket.assigns.user, %{hide: !socket.assigns.user.hide_aquired_items}) do
      {:ok, _user} ->
        {:noreply, assign(socket, :user, Accounts.get_user!(socket.assigns.user.id))}

      {:error, _changeset} -> {:noreply, socket}
    end
  end

  def handle_event("toggle", %{"moderate" => _}, socket) do
    {:noreply, assign(socket, :moderate, !socket.assigns.moderate)}
  end

  def handle_event("edit", %{"display" => id}, socket) do
    display = Gallery.get_display!(id)

    {:noreply, socket
    |> assign(:changeset, Gallery.change_display(display, %{}))
    |> assign(:room_options, Gallery.list_room_options())}
  end

  def handle_event("edit", %{"location" => id}, socket) do
    {:noreply, socket
    |> assign(:changeset, Gallery.change_location(Gallery.get_location!(id), %{}))
    |> assign(:region_options, Gallery.list_region_options())}
  end

  def handle_event("edit", %{"item" => id}, socket) do
    {:noreply, socket
    |> assign(:changeset, Gallery.change_item(Gallery.get_item!(id), %{}))
    |> assign(:display_options, Gallery.list_display_options())
    |> assign(:location_options, Gallery.list_location_options())}
  end

  def handle_event("edit", %{"mod" => id}, socket) do
    {:noreply, assign(socket, :changeset, Gallery.change_mod(Gallery.get_mod!(id), %{}))}
  end

  def handle_event("edit", %{"region" => id}, socket) do
    {:noreply, assign(socket, :changeset, Gallery.change_region(Gallery.get_region!(id), %{}))}
  end

  def handle_event("edit", %{"room" => id}, socket) do
    {:noreply, assign(socket, :changeset, Gallery.change_room(Gallery.get_room!(id), %{}))}
  end

  def handle_event("edit", %{"character" => id}, socket) do
    character = Enum.find(socket.assigns.user.characters, & &1.id == String.to_integer(id))
    {:noreply, assign(socket, :changeset, Accounts.change_character(character))}
  end

  def handle_event("cancel", _params, socket), do: {:noreply, assign(socket, :changeset, nil)}

  def handle_event("validate", params, socket) do
    data = socket.assigns.changeset.data
    changeset =
      case params do
        %{"character" => params} -> Accounts.change_character data, params
        %{"item" => params} ->      Gallery.change_item       data, params
        %{"display" => params} ->   Gallery.change_display    data, params
        %{"room" => params} ->      Gallery.change_room       data, params
        %{"location" => params} ->  Gallery.change_location   data, params
        %{"region" => params} ->    Gallery.change_region     data, params
        %{"mod" => params} ->       Gallery.change_mod        data, params
      end
    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", params, socket) do

    data = socket.assigns.changeset.data
    changeset =
      case params do
        %{"character" => params} ->
          Accounts.change_character data, Map.put(params, "user_id", socket.assigns.user.id)
        %{"item" => params} ->      Gallery.change_item       data, params
        %{"display" => params} ->   Gallery.change_display    data, params
        %{"room" => params} ->      Gallery.change_room       data, params
        %{"location" => params} ->  Gallery.change_location   data, params
        %{"region" => params} ->    Gallery.change_region     data, params
        %{"mod" => params} ->       Gallery.change_mod        data, params
      end

    case Repo.insert_or_update(changeset) do
      {:ok, _entry} ->
        {:noreply, socket
        |> assign(:changeset, nil)
        |> assign(:items, Gallery.list_items(socket.assigns.user))
        |> assign(:user, Accounts.get_user!(socket.assigns.user.id))}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_event("delete", %{"character" => id}, socket) do
    character = Enum.find(socket.assigns.user.characters, & &1.id == String.to_integer(id))
    case Accounts.delete_character(character) do
      {:ok, _character} ->
        {:noreply, assign(socket, :user, Accounts.get_user!(socket.assigns.user.id))}

      {:error, _reason} ->
        {:noreply, socket}
    end
  end

  def handle_event("delete", _params, socket) do
    case Repo.delete(socket.assigns.changeset.data) do
      {:ok, _struct} ->
        {:noreply, socket
        |> assign(:changeset, nil)
        |> assign(:filter, nil)
        |> assign(:user, Accounts.get_user!(socket.assigns.user.id))}

      {:error, _reason} -> socket
    end
  end

  def handle_event("select-tab", %{"selection" => action}, socket) do
    {:noreply, push_patch(socket, to: Routes.lotd_path(socket, String.to_atom(action)))}
  end

  def handle_event("select-room", %{"id" => id}, socket) do
    {:noreply, socket
    |> assign(:room_id, String.to_integer(id))
    |> assign_displays
    |> assign_items}
  end

  def handle_event("select-display", %{"id" => id}, socket) do
    {:noreply, socket
    |> assign(:display_id, String.to_integer(id))
    |> assign_items}
  end

  def handle_event("unselect-display", _params, socket) do
    {:noreply, socket
    |> assign(:display_id, nil)
    |> assign_items}
  end

  def handle_event("select-region", %{"id" => id}, socket) do
    {:noreply, socket
    |> assign(:region_id, String.to_integer(id))
    |> assign_locations
    |> assign_items}
  end

  def handle_event("select-location", %{"id" => id}, socket) do
    {:noreply, socket
    |> assign(:location_id, String.to_integer(id))
    |> assign_items}
  end

  def handle_event("unselect-location", _params, socket) do
    {:noreply, socket
    |> assign(:location_id, nil)
    |> assign_items}
  end

  def handle_event("select-mod", %{"id" => id}, socket) do
    {:noreply, socket
    |> assign(:mod_id, String.to_integer(id))
    |> assign_items}
  end

  def handle_event("select-character", %{"id" => id}, socket) do
    if String.to_integer(id) in Enum.map(socket.assigns.user.characters, & &1.id) do
      case Accounts.update_user(socket.assigns.user, %{active_character_id: id}) do
        {:ok, user} ->
          {:noreply, socket
          |> assign(:user, Accounts.preload_user_associations(user))
          |> assign_displays
          |> assign_locations
          |> assign_items}

        {:error, _reason} ->
          {:noreply, put_flash(socket, :error, gettext "Something went wrong.")}
      end
    else
      {:noreply, put_flash(socket, :error, gettext "This is not your character, hacker!")}
    end
  end

  def handle_event("toggle-hide", _params, socket) do
    hide = socket.assigns.user.hide_aquired_items
    case Accounts.update_user(socket.assigns.user, %{hide_aquired_items: !hide}) do
      {:ok, user} ->
        user = Map.put(socket.assigns.user, :hide_aquired_items, user.hide_aquired_items)
        broadcast("user-id:#{user.id}", {:update_user, user})
        {:noreply, socket}
      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, gettext "Could not toggle hide status.")}
    end
  end

  def handle_info({:update_user, user}, socket) do
    {:noreply, assign(socket, :user, user)}
  end
end
