defmodule LotdWeb.LayoutView do
  use LotdWeb, :view

  def add_button(conn) do
    text =  [icon("plus"), content_tag(:span, "Add")]
    case current_module(conn.path_info) do
      :character ->
        link(text, to: Routes.character_path(conn, :new), class: "button")
      _ ->
    end
  end

  def logout_button(conn) do
    link [icon("off", class: "is-small"), content_tag(:span, "Logout")],
      to: Routes.session_path(conn, :delete, conn.assigns.current_user.id),
      method: "delete",
      class: "button has-icons has-text-centered",
      title: "Logout #{conn.assigns.current_user.nexus_name}"
  end

  defp current_module(path_info) do
    if path_info == [], do: nil, else: path_info |> List.first() |> String.to_atom()
  end

  defp get_path(conn, module) do
    case module do
      :item -> Routes.item_path(conn, :index)
      :character -> Routes.character_path(conn, :index)
      :user -> Routes.user_path(conn, :index)
      _ -> Routes.page_path(conn, :index)
    end
  end

  def menu_link(conn, module, title, opts \\ []) do
    active = if current_module(conn.path_info) == module, do: " is-active", else: ""
    class = Keyword.get(opts, :class, "") <> active
    tag = Keyword.get(opts, :tag, :li)
    path = get_path(conn, module)
    content_tag tag, link(title, to: path), class: class
  end

  def unique_view_name(view_module, view_template) do
    [action, "html"] = String.split(view_template, ".")

    view_module
    |> Phoenix.Naming.resource_name()
    |> String.replace("_view", "/#{action}")
  end
end
