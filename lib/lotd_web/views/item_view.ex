defmodule LotdWeb.ItemView do
  use LotdWeb, :view

  def assoc_link(assoc, title) do
    if assoc.url, do:
      link(assoc.name,
        data_placement: "bottom",
        to: assoc.url,
        target: "_blank",
        title: title,
        phx_hook: "tooltip"
      ),
    else:
      content_tag :span, assoc.name,
        class: "text-secondary",
        data_placement: "bottom",
        title: title,
        phx_hook: "tooltip"
  end

  def check_item(moderator) do
    if moderator,
      do: icon("edit", class: "text-primary", phx_click: "toggle", phx_value_field: "moderate"),
      else: icon("active")
  end

  def details_cell(nil, visibility),
  do: content_tag(:td, "", class: "d-none d-#{visibility}-table-cell small")

  def details_cell(object, visibility) do
    class = "d-none d-#{visibility}-table-cell small"

    if object.url do
      content_tag(:td, link(object.name, to: object.url, class: "text-dark", target: "_blank"), class: class)
    else
      content_tag(:td, content_tag(:span, object.name, class: "text-muted"), class: class)
    end
  end

  def name(item, search) do
    if String.length(search) > 2 do
      case String.split(item.name, [search, String.capitalize(search)], parts: 2) do
        [name] -> name
        ["", name] -> [ content_tag(:mark, String.capitalize(search), class: "px-0"), name ]
        [prefix, suffix] ->
          if String.last(prefix) == " ",
            do: [ prefix, content_tag(:mark, String.capitalize(search), class: "px-0"), suffix ],
            else: [ prefix, content_tag(:mark, search, class: "px-0"), suffix ]
      end
    else
      item.name
    end
  end
end
