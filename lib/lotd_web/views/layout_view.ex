defmodule LotdWeb.LayoutView do
  use LotdWeb, :view

  def add_button(conn) do
    text =  [icon("plus"), content_tag(:span, "Add")]
    case module(conn) do
      :mod ->
        if admin?(conn), do: link(text, to: get_path(conn, :new), class: "dropdown-item")
      :user ->
        nil
      :character ->
        link(text, to: get_path(conn, :new), class: "dropdown-item")
      _ ->
        if moderator?(conn), do: link(text, to: get_path(conn, :new), class: "dropdown-item")
    end
  end

  def logout_button(conn) do
    link [icon("off"), content_tag(:span, "Logout", class: "d-md-none")],
      to: Routes.session_path(conn, :delete, user(conn).id),
      method: "delete",
      id: "logout-button",
      class: "nav-link",
      title: "Logout #{user(conn).nexus_name}"
  end

  def menu_link(conn, module) do
    title = Atom.to_string(module) |> String.capitalize()
    active = if module(conn) == module, do: " is-active", else: ""
    path = get_path(conn, :index, module: module)
    content_tag :li, link("#{title}s", class: "nav-link", to: path), class: "nav-item " <> active
  end

  def dropdown_link(conn, module) do
    active = if module(conn) == module, do: " is-active", else: ""
    title = Atom.to_string(module) |> String.capitalize()
    path = get_path(conn, :index, module: module)
    link("#{title}s", class: "dropdown-item#{active}", to: path)
  end

  def unique_view_name(view_module, view_template) do
    [action, "html"] = String.split(view_template, ".")

    view_module
    |> Phoenix.Naming.resource_name()
    |> String.replace("_view", "/#{action}")
  end
end
