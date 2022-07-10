defmodule LotdWeb.LotdLive do

  use LotdWeb, :live_view

  alias Lotd.{Accounts, Gallery}

  @requires_character ~w(update_character)a
  @requires_moderator ~w(create_item update_item create_display update_display create_location update_location create_mod update_mod)a
  @requires_admin ~w(create_region update_region create_room update_room users)a
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

    Phoenix.PubSub.subscribe(Lotd.PubSub, "all")

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
    |> assign_mods
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

  defp assign_mods(socket) do
    user = socket.assigns.user
    search_query = Ecto.Changeset.get_field(socket.assigns.search_changeset, :query)

    mods =
      if search_query do
        socket.assigns.mods
        |> Enum.map(& Map.put(&1, :similarity, FuzzyCompare.similarity(&1.name, search_query)))
        |> Enum.sort_by(& &1.similarity, :desc)
        |> Enum.filter(& &1.similarity > 0.9)
        |> Enum.take(10)
      else
        if user && user.active_character do
          Enum.filter(socket.assigns.mods, & &1.id in user.active_character.mods)
        else
          socket.assigns.mods
        end
      end
      |> Enum.map(fn %{id: id} = mod ->
          count = Enum.count(Enum.filter(socket.assigns.items, & &1.mod_id == id))
          Map.put(mod, :count, count)
        end)

    assign(socket, :current_mods, mods)
  end

  defp assign_items(socket) do
    user = socket.assigns.user
    search_query = Ecto.Changeset.get_field(socket.assigns.search_changeset, :query)

    items =
      if user && user.active_character do
        Enum.filter(socket.assigns.items, & &1.mod_id in user.active_character.mods )
      else
        socket.assigns.items
      end

    current_items =
      if search_query do
        items
        |> Enum.map(& Map.put(&1, :similarity, FuzzyCompare.ChunkSet.standard_similarity(&1.name, search_query)))
        |> Enum.sort_by(& &1.similarity, :desc)
        |> Enum.take(50)
      else
        cond do
          socket.assigns.live_action in [:gallery, :create_display, :update_display] ->
            case socket.assigns.display_id do
              nil ->
                ids = Enum.map(socket.assigns.current_displays, & &1.id)
                Enum.filter(items, & &1.display_id in ids)

              id ->
                Enum.filter(items, & &1.display_id == id)
            end
          socket.assigns.live_action in [:locations, :create_location, :update_location] ->
            case socket.assigns.location_id do
              nil ->
                ids = Enum.map(socket.assigns.current_locations, & &1.id)
                Enum.filter(items, & &1.location_id in ids)

              id ->
                Enum.filter(items, & &1.location_id == id)
            end
          :mods ->
            Enum.filter(items, & &1.mod_id == socket.assigns.mod_id)

          true ->
            []
        end
      end

    assign(socket, :current_items, Enum.take(current_items, 200))
  end

  def handle_params(unsigned_params, uri, socket) do
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

      # assign id for pages that need it
      socket.assigns.live_action == :update_item ->
        {:noreply, socket
        |> assign(:id, Map.get(unsigned_params, "id"))
        |> assign_items}

      # redirect from index page
      socket.assigns.live_action == :index ->
        {:noreply, push_patch(socket, to: Routes.lotd_path(socket, :gallery))}

      # invalid url -> redirect to gallery
      socket.assigns.live_action == :unknown_url ->
        {:noreply, socket
        |> put_flash(:error, uri <> gettext(" doesn't exist."))
        |> push_patch(to: Routes.lotd_path(socket, :gallery))}

      true ->
        {:noreply, assign_items(socket)}
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

        <% :create_item -> %>
          <.live_component
            item_id={nil}
            id="create-item-component"
            module={LotdWeb.Live.ItemComponent}
            display_id={@display_id}
            display_options={Enum.map(@displays, & {&1.name, &1.id})}
            location_id={@location_id}
            location_options={Enum.map(@locations, & {&1.name, &1.id})}
            mod_id={@mod_id}
            mod_options={Enum.map(@mods, & {&1.name, &1.id})}
          />

        <% :update_item -> %>
          <.live_component
            item_id={@id}
            id="update-item-component"
            module={LotdWeb.Live.ItemComponent}
            display_id={@display_id}
            display_options={Enum.map(@displays, & {&1.name, &1.id})}
            location_id={@location_id}
            location_options={Enum.map(@locations, & {&1.name, &1.id})}
            mod_id={@mod_id}
            mod_options={Enum.map(@mods, & {&1.name, &1.id})}
          />

        <% :create_display -> %>
          <.live_component
            display_id={nil}
            id="create-display-component"
            items={[]}
            module={LotdWeb.Live.DisplayComponent}
            room_id={@room_id}
            room_options={Enum.map(@rooms, & {&1.name, &1.id})}
          />

        <% :update_display -> %>
          <.live_component
            display_id={@display_id}
            items={@current_items}
            id="update-display-component"
            module={LotdWeb.Live.DisplayComponent}
            room_id={@room_id}
            room_options={Enum.map(@rooms, & {&1.name, &1.id})}
          />

        <% :create_location -> %>
          <.live_component
            location_id={nil}
            id="create-location-component"
            items={[]}
            module={LotdWeb.Live.LocationComponent}
            region_id={@region_id}
            region_options={Enum.map(@regions, & {&1.name, &1.id})}
          />

        <% :update_location -> %>
          <.live_component
            location_id={@location_id}
            items={@current_items}
            id="update-location-component"
            module={LotdWeb.Live.LocationComponent}
            region_id={@region_id}
            region_options={Enum.map(@regions, & {&1.name, &1.id})}
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

  def handle_event("search", %{"search" => params}, socket) do
    {:noreply, socket
    |> assign(:search_changeset, search_changeset(params))
    |> assign_displays
    |> assign_locations
    |> assign_items}
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
    |> assign(:search_changeset, search_changeset(%{}))
    |> assign_displays
    |> assign_items}
  end

  def handle_event("unselect-display", _params, socket) do
    {:noreply, socket
    |> assign(:display_id, nil)
    |> assign(:search_changeset, search_changeset(%{}))
    |> assign_displays
    |> assign_items}
  end

  def handle_event("select-region", %{"id" => id}, socket) do
    {:noreply, socket
    |> assign(:region_id, String.to_integer(id))
    |> assign(:search_changeset, search_changeset(%{}))
    |> assign_locations
    |> assign_items}
  end

  def handle_event("select-location", %{"id" => id}, socket) do
    {:noreply, socket
    |> assign(:location_id, String.to_integer(id))
    |> assign(:search_changeset, search_changeset(%{}))
    |> assign_locations
    |> assign_items}
  end

  def handle_event("unselect-location", _params, socket) do
    {:noreply, socket
    |> assign(:location_id, nil)
    |> assign(:search_changeset, search_changeset(%{}))
    |> assign_locations()
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

  def handle_info({:update_displays, displays}, socket) do
    socket =
      if not is_nil(socket.assigns.display_id) and socket.assigns.display_id not in displays do
        assign(socket, :display_id, nil)
      else
        socket
      end

    {:noreply, socket
    |> assign(:displays, displays)
    |> assign_displays
    |> assign_items}
  end

  def handle_info({:update_locations, locations}, socket) do
    socket =
      if not is_nil(socket.assigns.location_id) and socket.assigns.location_id not in locations do
        assign(socket, :location_id, nil)
      else
        socket
      end

    {:noreply, socket
    |> assign(:locations, locations)
    |> assign_locations
    |> assign_items}
  end

  def handle_info({:update_items, items}, socket) do
    {:noreply, socket
    |> assign(:items, items)
    |> assign_displays
    |> assign_locations
    |> assign_mods
    |> assign_items}
  end
end
