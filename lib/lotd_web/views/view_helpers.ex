defmodule LotdWeb.ViewHelpers do
  @moduledoc """
  Conveniences for all views.
  """

  use Phoenix.HTML

  import Phoenix.Controller, only: [view_module: 1]
  import Phoenix.View, only: [render: 3]

  alias LotdWeb.Router.Helpers, as: Routes

  def authenticated?(conn), do: not is_nil(conn.assigns.current_user)
  def moderator?(conn), do: authenticated?(conn) && conn.assigns.current_user.moderator
  def admin?(conn), do: authenticated?(conn) && conn.assigns.current_user.admin
  def user(conn), do: conn.assigns.current_user
  def character(conn), do: authenticated?(conn) && conn.assigns.current_user.active_character

  def get_path(conn, action, opts \\ []) do
    id = Keyword.get(opts, :id, nil)
    module = Keyword.get(opts, :module, module(conn))

    case module do
      :character ->
        if id,
          do: Routes.character_path(conn, action, id),
          else: Routes.character_path(conn, action)
      :display ->
        if id,
          do: Routes.display_path(conn, action, id),
          else: Routes.display_path(conn, action)
      :quest ->
        if id,
          do: Routes.quest_path(conn, action, id),
          else: Routes.quest_path(conn, action)
      :location ->
        if id,
          do: Routes.location_path(conn, action, id),
          else: Routes.location_path(conn, action)
      :mod ->
        if id,
          do: Routes.mod_path(conn, action, id),
          else: Routes.mod_path(conn, action)
      :user ->
        if id,
          do: Routes.user_path(conn, action, id),
          else: Routes.user_path(conn, action)
      _ ->
        if id,
          do: Routes.item_path(conn, action, id),
          else: Routes.item_path(conn, action)
    end
  end

  def moderator_actions(conn, struct) do
    edit_path = get_path(conn, :edit, id: struct.id)
    delete_path = get_path(conn, :delete, id: struct.id)

    content_tag :td, [
      link(icon("pencil"), to: edit_path),
      link(icon("cancel", class: "has-text-danger"), to: delete_path, method: "delete")
    ]
  end

  def active_character_id(conn), do: character(conn).id

  def character_item_ids(conn), do: Enum.map(character(conn).items, fn i -> i.id end)

  def character_mod_ids(conn), do: Enum.map(character(conn).mods, fn m -> m.id end)

  def module(conn) do
    conn
    |> view_module()
    |> Phoenix.Naming.resource_name()
    |> String.replace("_view", "")
    |> String.to_atom()
  end

  def name_link(%{} = struct) do
    if struct.url, do: link(struct.name, to: struct.url, target: "_blank"), else: "#{struct.name}"
  end

  def icon(name, opts \\ [] ) do
    class = Keyword.get(opts, :class, "")
    title = Keyword.get(opts, :title)

    icon = content_tag :i, "", class: "icon-#{name}"
    content_tag :span, icon, class: "icon #{class}", title: title
  end

  def render_form(conn, action) do
    path = if action == :update,
      do: get_path(conn, :update, id: conn.assigns.changeset.data.id),
      else: get_path(conn, :create)
    module = module(conn)

    render LotdWeb.LayoutView, "form.html",
      action: path,
      changeset: conn.assigns.changeset,
      context: module,
      mods: Map.get(conn.assigns, :mods),
      submit_button_text: Atom.to_string(action) |> String.capitalize()
  end

  def select_options(structures), do: for s <- structures, do: {s.name, s.id}

  def time(time), do: content_tag(:time, "", datetime: NaiveDateTime.to_iso8601(time) <> "Z")

end
