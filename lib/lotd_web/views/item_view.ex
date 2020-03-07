defmodule LotdWeb.ItemView do
  use LotdWeb, :view

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
    case String.split(item.name, search, parts: 2) do
      [name] -> name
      ["", name] -> [ content_tag(:mark, search, class: "px-0"), name ]
      [prefix, suffix] -> [ prefix, content_tag(:mark, search, class: "px-0"), suffix ]
    end
  end
end
