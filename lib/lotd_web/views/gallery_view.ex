defmodule LotdWeb.GalleryView do
  use LotdWeb, :view

  alias Lotd.Gallery
  alias Lotd.Accounts.Character
  alias Lotd.Gallery.{Room, Display, Region, Location}

  @min_search_chars 3

  def entry_base(map, type, active \\ nil) do
    opts = [
      class: "list-group-item small p-1 list-group-item-action #{map.id == active}",
      phx_click: "filter"
    ]
    content_tag :li, map.name, Keyword.put(opts, type, map.id)
  end

  def character(nil), do: nil
  def character(user), do: user.active_character

  def character?(struct), do: struct.__struct__ == Character

  def filter?(socket) do
    cond do
      socket.assigns.filter_mod -> :mod
      socket.assigns.filter_display -> :display
      socket.assigns.filter_room -> :room
      socket.assigns.filter_location -> :location
      socket.assigns.filter_region -> :region
      true -> nil
    end
  end

  def filtered_struct(socket) do
    case filter?(socket) do
      :display ->
        Enum.find socket.assigns.displays, & &1.id == socket.assigns.filter_display

      :room ->
        Enum.find socket.assigns.rooms, & &1.id == socket.assigns.filter_room

      :location ->
        socket.assigns.regions
        |> Enum.find(& &1.id == socket.assigns.filter_region)
        |> Map.get(:locations)
        |> Enum.find(& &1.id == socket.assigns.filter_location)

      :region ->
        Enum.find socket.assigns.regions, & &1.id == socket.assigns.filter_region

      :mod ->
        Enum.find socket.assigns.mods, & &1.id == socket.assigns.filter_mod

      nil -> nil
    end
  end

  def form_action(changeset), do: if changeset.data.id, do: :update, else: :insert

  def form_btn_text(changeset), do: if changeset.data.id, do: "Update", else: "Create"

  def form_heading_text(changeset) do
    if changeset.data.id,
      do: "Edit #{type(changeset.data)}",
      else: "Add #{type(changeset.data)}"
  end

  def filtered?(filter, struct) do
    case struct do
      %Room{} ->
        (filter.__struct__ == struct.__struct__ && filter.id == struct.id) ||
        (filter.__struct__ == Display && filter.room_id == struct.id)

      %Region{} ->
        (filter.__struct__ == struct.__struct__ && filter.id == struct.id) ||
        (filter.__struct__ == Location && filter.region_id == struct.id)

      _ ->
        not is_nil(filter) && filter.__struct__ == struct.__struct__ && filter.id == struct.id
    end
  end

  def locations(regions, filter) do
    regions
    |> Enum.find(& &1.id == filter)
    |> Map.get(:locations)
  end

  def searching?(query), do: String.length(query) > @min_search_chars

  def tab(number, title, active, search) do
    active = if number == active && not searching?(search), do: " active"
    content_tag :li,
      link(title, to: "#", class: "nav-link #{active}", phx_click: "tab", phx_value_tab: number), class: "nav-item"
  end

  def type(struct) do
    struct.__struct__
    |> to_string()
    |> String.split(".")
    |> List.last()
  end
end
