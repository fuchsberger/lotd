defmodule LotdWeb.GalleryView do
  use LotdWeb, :view

  alias Lotd.Accounts.Character
  alias Lotd.Gallery.{Item, Room, Display, Region, Location, Mod}
  alias LotdWeb.{EntryView}

  @entry_class "list-group-item small p-1 list-group-item-action d-flex justify-content-between align-items-center"

  def active?(user, mod), do: Enum.member?(active_character(user).mods, mod.id)

  def active_character(user), do: Enum.find(user.characters, & &1.id == user.active_character_id)

  def active_mods(nil, _mods), do: false

  def active_mods(user, mods) do
    Enum.filter(mods, & Enum.member?(active_character(user).mods, &1.id))
  end

  def assoc_link(assoc) do
    #TODO: fix url
    if false && assoc.url,
      do: link(assoc.name, class: "text-black-50", to: assoc.url, target: "_blank"),
      else: content_tag(:span, assoc.name, class: "text-black-50")
  end

  def inactive_mods(user, mods) do
    Enum.reject(mods, & Enum.member?(active_character(user).mods, &1.id))
  end

  def submit_button(changeset) do
    text =
      case {changeset.data.__struct__, changeset.data.__meta__.state} do
        {_, :built} -> "Create"
        {%Character{}, :loaded} -> "Rename"
        {%Region{}, :loaded} -> "Rename"
        {%Room{}, :loaded} -> "Rename"
        {_, :loaded} -> "Update"
      end
    submit text, class: "btn btn-sm btn-outline-primary"
  end

  def edit?(changeset), do: changeset && changeset.data.__meta__.state == :loaded

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

  def entry_class(active? \\ false) do
    "list-group-item small list-group-item-action p-1\
    d-flex justify-content-between align-items-center\
    #{if active?, do: " active"}"
  end

  def filter?(_type, _id, nil), do: false

  def filter?(type, id, {filter_type, filter_id}), do: type == filter_type && id == filter_id

  def form_action(changeset), do: if changeset.data.id, do: :update, else: :insert

  def form_btn_text(changeset), do: if changeset.data.id, do: "Update", else: "Create"

  def form_heading_text(changeset) do
    if changeset.data.id,
      do: "Edit #{type(changeset.data)}",
      else: "Add #{type(changeset.data)}"
  end

  def hide_text(true), do: "show"
  def hide_text(false), do: "hide"

  def info(title), do: render EntryView, "info.html", title: title

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

  defp options(type, id, filter) do
    {class, action} = if id == filter, do: {" active", "clear"}, else: {"", "filter"}

    [class: "#{@entry_class}#{class}", phx_click: action]
    |> Keyword.put(String.to_atom("phx_value_#{Atom.to_string(type)}"), id)
  end

  def searching?(query), do: String.length(query) > 2

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
