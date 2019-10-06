defmodule LotdWeb.LayoutView do
  use LotdWeb, :view

  def add_button(conn) do
    text =  [icon("plus"), content_tag(:span, "Add")]
    case module(conn) do
      :mod ->
        if admin?(conn), do: link(text, to: get_path(conn, :new), class: "button")
      :user ->
        nil
      :character ->
        link(text, to: get_path(conn, :new), class: "button")
      _ ->
        if moderator?(conn), do: link(text, to: get_path(conn, :new), class: "button")
    end
  end

  def logout_button(conn) do
    link [icon("off", class: "is-small"), content_tag(:span, "Logout")],
      to: Routes.session_path(conn, :delete, user(conn).id),
      method: "delete",
      class: "button has-icons has-text-centered",
      title: "Logout #{user(conn).nexus_name}"
  end

  def menu_link(conn, module, opts \\ []) do
    title = Atom.to_string(module) |> String.capitalize()
    active = if module(conn) == module, do: " is-active", else: ""
    class = if Keyword.has_key?(opts, :navbar),
      do: "navbar-item is-hidden-desktop" <> active,
      else: active
    tag = if Keyword.has_key?(opts, :navbar), do: :div, else: :li
    path = get_path(conn, :index, module: module)
    content_tag tag, link("#{title}s", to: path), class: class
  end

  def unique_view_name(view_module, view_template) do
    [action, "html"] = String.split(view_template, ".")

    view_module
    |> Phoenix.Naming.resource_name()
    |> String.replace("_view", "/#{action}")
  end
end
