defmodule LotdWeb.GalleryView do
  use LotdWeb, :view

  alias Lotd.Gallery
  alias Lotd.Accounts.Character
  alias Lotd.Gallery.{Room, Display, Region, Location, Mod}
  alias LotdWeb.EntryView

  @entry_class "list-group-item small p-1 list-group-item-action d-flex justify-content-between align-items-center"
  @min_search_chars 3

  def character?(struct), do: struct.__struct__ == Character

  def new?(_type, nil), do: false

  def new?(type, changeset) do
    case {type, changeset.data} do
      {:character, %Character{} = data} -> is_nil(Map.get(data, :id))
      {:mod, %Mod{} = data} -> is_nil(Map.get(data, :id))
      {_, _} -> false
    end
  end

  def edit?(_type, nil), do: false

  def edit?(type, changeset) do
    case {type, changeset.data} do
      {:character, %Character{} = data} -> not is_nil(Map.get(data, :id))
      {_, _} -> false
    end
  end

  def edit_character?(changeset) do
    changeset && character?(changeset.data) && not is_nil(Map.get(changeset.data, :id))
  end

  def divider(type, right \\ nil, add \\ false, prefix \\ "") do
    add = if add, do: Atom.to_string(type), else: nil
    title = if is_atom(type),
      do: "#{prefix}#{type |> Atom.to_string() |> String.capitalize()}s",
      else: type

    render EntryView, "divider.html", add: add, right: right, title: title
  end

  def entry(template, opts), do: render EntryView, template, opts

  def entries(template, list, opts), do: render_many list, EntryView, template, opts

  def entry(type, map, filter) do
    content_tag :li, [
      content_tag(:span, map.name, class: "flex-grow-1"),
      content_tag(:span, map.count, class: "badge badge-light badge-pill")
    ], options(type, map.id, filter)
  end

  def entry(:mod, mod, filter, active?) do
    content_tag :li, [
      content_tag(:span, [toggler(mod.id, active?), mod.name], class: "flex-grow-1"),
      content_tag(:span, mod.item_count, class: "badge badge-light badge-pill")
    ], options(:mod, mod.id, filter)
  end

  def entry(type, id, name, filter), do: content_tag :li, name, options(type, id, filter)

  def filter?(nil, _type), do: false
  def filter?(entry, :display), do: entry && entry.__struct__ == Display && entry.id
  def filter?(entry, :location), do: entry && entry.__struct__ == Location && entry.id
  def filter?(entry, :mod), do: entry && entry.__struct__ == Mod && entry.id

  def filter?(entry, :room) do
    case entry do
      %Display{} -> entry.room_id
      %Room{} -> entry.id
      _ -> false
    end
  end

  def filter?(entry, :region) do
    case entry do
      %Location{} -> entry.region_id
      %Region{} -> entry.id
      _ -> false
    end
  end

  def form_action(changeset), do: if changeset.data.id, do: :update, else: :insert

  def form_btn_text(changeset), do: if changeset.data.id, do: "Update", else: "Create"

  def form_heading_text(changeset) do
    if changeset.data.id,
      do: "Edit #{type(changeset.data)}",
      else: "Add #{type(changeset.data)}"
  end

  def info(title), do: render EntryView, "info.html", title: title

  defp options(type, id, filter) do
    {class, action} = if id == filter, do: {" active", "clear"}, else: {"", "filter"}

    [class: "#{@entry_class}#{class}", phx_click: action]
    |> Keyword.put(String.to_atom("phx_value_#{Atom.to_string(type)}"), id)
  end

  def searching?(query), do: String.length(query) > @min_search_chars

  def tab(number, title, active, search) do
    active = if number == active && not searching?(search), do: " active"
    content_tag :li,
      link(title, to: "#", class: "nav-link #{active}", phx_click: "tab", phx_value_tab: number), class: "nav-item"
  end

  def toggler(id, active?) do
    action = if active?, do: "deactivate", else: "activate"

    link icon(if active?, do: "active", else: "inactive"),
      to: "#",
      phx_click: action,
      phx_value_mod: id,
      phx_hook: "tooltip",
      title: String.capitalize("#{action} Mod")
  end
end
