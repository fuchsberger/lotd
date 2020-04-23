defmodule LotdWeb.GalleryView do
  use LotdWeb, :view

  alias Lotd.Accounts.Character
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
