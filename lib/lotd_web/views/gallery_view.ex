defmodule LotdWeb.GalleryView do

  use LotdWeb, :view

  alias Lotd.Accounts.{Character, User}
  alias Lotd.Gallery.{Item, Room, Display, Region, Location, Mod}

  def active?(user, mod), do: Enum.member?(active_character(user).mods, mod.id)

  def active_character(user), do: Enum.find(user.characters, & &1.id == user.active_character_id)

  def count_tooltip(true), do: "Items remaining"
  def count_tooltip(_), do: "Total Items"

  def divider(type, right \\ nil, add \\ false, prefix \\ "") do
    add = if add, do: Atom.to_string(type), else: nil
    title = if is_atom(type),
      do: "#{prefix}#{type |> Atom.to_string() |> String.capitalize()}s",
      else: type

    render "divider.html", add: add, right: right, title: title
  end

  def edit?(changeset), do: changeset && changeset.data.__meta__.state == :loaded

  def filter?(nil, _type), do: false
  def filter?({ftype, _id}, type), do: ftype == type

  def filter?(_type, _id, nil), do: false
  def filter?(type, id, {filter_type, filter_id}), do: type == filter_type && id == filter_id

  def form_action(changeset), do: if changeset.data.id, do: :update, else: :insert

  def hide_text(true), do: "show"
  def hide_text(false), do: "hide"

  # types validations
  def is_character?(changeset), do: changeset && changeset.data.__struct__ == Character
  def is_display?(changeset), do: changeset && changeset.data.__struct__ == Display
  def is_item?(changeset), do: changeset && changeset.data.__struct__ == Item
  def is_location?(changeset), do: changeset && changeset.data.__struct__ == Location
  def is_mod?(changeset), do: changeset && changeset.data.__struct__ == Mod
  def is_region?(changeset), do: changeset && changeset.data.__struct__ == Region
  def is_room?(changeset), do: changeset && changeset.data.__struct__ == Room

  def name(name, search) do
    if String.length(search) > 2 do
      case String.split(name, [search, String.capitalize(search)], parts: 2) do
        [name] -> name
        ["", name] -> [ content_tag(:mark, String.capitalize(search), class: "px-0"), name ]
        [prefix, suffix] ->
          if String.last(prefix) == " ",
            do: [ prefix, content_tag(:mark, String.capitalize(search), class: "px-0"), suffix ],
            else: [ prefix, content_tag(:mark, search, class: "px-0"), suffix ]
      end
    else
      name
    end
  end

  def new?(changeset), do: changeset && changeset.data.__meta__.state == :built

  def displays(items) do
    items
    |> Enum.map(& &1.display)
    |> Enum.uniq()
    |> Enum.sort(&(&1.name < &2.name))
    |> Enum.map(fn display ->
        item_ids = items |> Enum.filter(& &1.display_id == display.id) |> Enum.map(& &1.id)
        Map.put(display, :items, item_ids)
      end)
  end

  def displays(displays, user, search, filter) do
    case user do
      nil ->
        displays
        |> filter(search, filter)
        |> Enum.map(& Map.put(&1, :item_count, Enum.count(&1.items)))

      %User{hide: false} ->
        displays
        |> filter(search, filter)
        |> Enum.map(& Map.put(&1, :item_count, Enum.count(&1.items)))

      %User{hide: true} ->
        character = Enum.find(user.characters, & &1.id == user.active_character_id)

        displays
        |> filter(search, filter)
        |> Enum.map(fn display ->
          count =
            display.items
            |> Enum.filter(& not Enum.member?(character.items, &1))
            |> Enum.count()

          Map.put(display, :item_count, count)
        end)
        |> Enum.filter(& &1.item_count > 0)
    end
  end

  def items(items, search, filter, user) do
    items
    |> filter(search, filter)
    |> filter_hide(user)
    |> Enum.take(200)
  end

  def locations(items) do
    items
    |> Enum.map(& &1.location)
    |> Enum.uniq()
    |> Enum.reject(& is_nil(&1))
    |> Enum.sort(&(&1.name < &2.name))
    |> Enum.map(fn location ->
        item_ids = items |> Enum.filter(& &1.location_id == location.id) |> Enum.map(& &1.id)
        Map.put(location, :items, item_ids)
      end)
  end

  def locations(locations, user, search, filter) do
    case user do
      nil ->
        locations
        |> filter(search, filter)
        |> Enum.map(& Map.put(&1, :item_count, Enum.count(&1.items)))

      %User{hide: false} ->
        locations
        |> filter(search, filter)
        |> Enum.map(& Map.put(&1, :item_count, Enum.count(&1.items)))

      %User{hide: true} ->
        character = Enum.find(user.characters, & &1.id == user.active_character_id)

        locations
        |> filter(search, filter)
        |> Enum.map(fn location ->
          count =
            location.items
            |> Enum.filter(& not Enum.member?(character.items, &1))
            |> Enum.count()

          Map.put(location, :item_count, count)
        end)
        |> Enum.filter(& &1.item_count > 0)
    end
  end

  def mods(items, user, search, filter) do
    mods =
      items
      |> Enum.map(& &1.mod)
      |> Enum.uniq()
      |> Enum.sort(&(&1.name < &2.name))
      |> Enum.map(fn mod ->
          item_ids = items |> Enum.filter(& &1.mod_id == mod.id) |> Enum.map(& &1.id)
          Map.put(mod, :items, item_ids)
        end)

    case user do
      nil ->
        mods
        |> filter(search, filter)
        |> Enum.map(& Map.put(&1, :item_count, Enum.count(&1.items)))

      %User{hide: false} ->
        mods
        |> filter(search, filter)
        |> Enum.map(& Map.put(&1, :item_count, Enum.count(&1.items)))

      %User{hide: true} ->
        character = Enum.find(user.characters, & &1.id == user.active_character_id)

        mods
        |> filter(search, filter)
        |> Enum.map(fn mod ->
          count =
            mod.items
            |> Enum.filter(& not Enum.member?(character.items, &1))
            |> Enum.count()

          Map.put(mod, :item_count, count)
        end)
    end
  end

  def inactive_mods(all_ids, active_mods) do
    Enum.filter(all_ids, fn {_name, id} ->
      active_ids = Enum.map(active_mods, & &1.id)
      not Enum.member?(active_ids, id)
    end)
  end

  def regions(locations, user, search) do
    regions =
      locations
      |> Enum.map(& &1.region)
      |> Enum.uniq()
      |> filter(search, nil)
      |> Enum.sort(&(&1.name < &2.name))
      |> Enum.map(fn region ->
        item_ids =
          locations
          |> Enum.filter(& &1.region_id == region.id)
          |> Enum.map(& &1.items)
          |> List.flatten()
        Map.put(region, :items, item_ids)
      end)

    case user do
      nil -> Enum.map(regions, & Map.put(&1, :item_count, Enum.count(&1.items)))
      %User{hide: false} -> Enum.map(regions, & Map.put(&1, :item_count, Enum.count(&1.items)))
      %User{hide: true} ->
        character = Enum.find(user.characters, & &1.id == user.active_character_id)

        Enum.map(regions, fn region ->
          count =
            region.items
            |> Enum.filter(& not Enum.member?(character.items, &1))
            |> Enum.count()

          Map.put(region, :item_count, count)
        end)
        |> Enum.filter(& &1.item_count > 0)
    end
  end

  def rooms(displays, user, search) do
    rooms =
      displays
      |> Enum.map(& &1.room)
      |> Enum.uniq()
      |> filter(search, nil)
      |> Enum.sort(&(&1.name < &2.name))
      |> Enum.map(fn room ->
        item_ids =
          displays
          |> Enum.filter(& &1.room_id == room.id)
          |> Enum.map(& &1.items)
          |> List.flatten()
        Map.put(room, :items, item_ids)
      end)

    case user do
      nil -> Enum.map(rooms, & Map.put(&1, :item_count, Enum.count(&1.items)))
      %User{hide: false} -> Enum.map(rooms, & Map.put(&1, :item_count, Enum.count(&1.items)))
      %User{hide: true} ->
        character = Enum.find(user.characters, & &1.id == user.active_character_id)

        Enum.map(rooms, fn room ->
          count =
            room.items
            |> Enum.filter(& not Enum.member?(character.items, &1))
            |> Enum.count()

          Map.put(room, :item_count, count)
        end)
        |> Enum.filter(& &1.item_count > 0)
    end
  end

  def filter([], _search, _filter), do: []

  def filter(list, search, filter) do
    case String.length(search) > 2 do
      false ->
        # apply filter
        case {List.first(list).__struct__, filter} do
          {_, nil} -> list

          {Display, {:display, id}} ->
            room_id = Enum.find(list, & &1.id == id).room_id
            Enum.filter(list, & &1.room_id == room_id)

          {Display, {:room, room_id}} -> Enum.filter(list, & &1.room_id == room_id)

          {Location, {:location, id}} ->
            region_id = Enum.find(list, & &1.id == id).region_id
            Enum.filter(list, & &1.region_id == region_id)

          {Location, {:region, region_id}} -> Enum.filter(list, & &1.region_id == region_id)

          {Item, {:display, id}} -> Enum.filter(list, & &1.display_id == id)
          {Item, {:location, id}} -> Enum.filter(list, & &1.location_id == id)
          {Item, {:mod, id}} -> Enum.filter(list, & &1.mod_id == id)

          {Item, {:region, id}} ->
            location_ids =
              list
              |> locations()
              |> Enum.filter(& &1.region_id == id)
              |> Enum.map(& &1.id)
            Enum.filter(list, & Enum.member?(location_ids, &1.location_id))

          {Item, {:room, id}} ->
            display_ids =
              list
              |> displays()
              |> Enum.filter(& &1.room_id == id)
              |> Enum.map(& &1.id)
            Enum.filter(list, & Enum.member?(display_ids, &1.display_id))

          {_, _} -> list
        end

      true ->
        # apply search
        search = String.downcase(search, :ascii)
        Enum.filter(list, fn entry ->
          String.contains?(String.downcase(entry.name, :ascii), search)
        end)
    end
  end

  def filter_hide(list, user) do
    case user do
      nil -> list
      %User{hide: false} -> list
      %User{hide: true} ->
        character = Enum.find(user.characters, & &1.id == user.active_character_id)
        Enum.reject(list, & Enum.member?(character.items, &1.id))
    end
  end

  def searching?(query), do: String.length(query) > 2

  def submit_button(changeset) do
    text =
      case {changeset.data.__struct__, changeset.data.__meta__.state} do
        {_, :built} -> "Create"
        {Character, :loaded} -> "Rename"
        {Region, :loaded} -> "Rename"
        {Room, :loaded} -> "Rename"
        {_, :loaded} -> "Update"
      end
    submit text, class: "btn btn-sm btn-outline-primary"
  end

  def tab(number, title, active, search) do
    assigns = []
    active = if number == active && not searching?(search), do: " active"
    ~L"""
    <li class='nav-item'>
      <a href='#' class='nav-link <%= active %>' phx-click='tab' phx-value-tab='<%= number %>'><%= title %></a>
    </li>
    """
  end
end
