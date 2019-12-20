defmodule LotdWeb.ViewHelpers do
  @moduledoc """
  Conveniences for all views.
  """

  use Phoenix.HTML

  import Phoenix.Controller, only: [view_module: 1]
  import Phoenix.View, only: [render: 3]
  import Phoenix.LiveView, only: [ live_link: 2 ]

  alias LotdWeb.Router.Helpers, as: Routes

  # access control

  def authenticated?(%Plug.Conn{} = conn), do: not is_nil(conn.assigns.current_user)

  def authenticated?(%Phoenix.LiveView.Socket{} = socket), do: Map.has_key?(socket.assigns, :user)

  def moderator?(%Plug.Conn{} = conn),
    do: authenticated?(conn) && conn.assigns.current_user.moderator

  def moderator?(%Phoenix.LiveView.Socket{} = socket),
    do: authenticated?(socket) && socket.assigns.user.moderator

  def admin?(%Plug.Conn{} = conn),
    do: authenticated?(conn) && conn.assigns.current_user.admin

  def admin?(%Phoenix.LiveView.Socket{} = socket),
    do: authenticated?(socket) && socket.assigns.user.admin

  # flash messages

  def error(msg) do
    if msg, do: render LotdWeb.LayoutView, "flash.html", color: "danger", msg: msg
  end

  def info(msg) do
    if msg, do: render LotdWeb.LayoutView, "flash.html", color: "info", msg: msg
  end

  def user(conn), do: conn.assigns.current_user
  def character(conn), do: authenticated?(conn) && conn.assigns.current_user.active_character

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

  def icon(name, opts \\ [] ) do
    content_tag :i, "",
      [{:class, "icon-#{name} #{Keyword.get(opts, :class, "")}"} | Keyword.delete(opts, :class)]
  end

  def icon_active(list, id) do
    active = not is_nil(Enum.find(list, fn x -> x.id == id end))
    if active, do: "icon-active", else: "icon-inactive"
  end

  def select_options(structures), do: for s <- structures, do: {s.name, s.id}

  def th_edit do
    icon = content_tag :i, "", class: "icon-edit"
    content_tag :th, icon, class: "text-center"
  end

  def title(name, nil, total) do
    [name, content_tag(:span, "(#{total})", class: "badge badge-light")]
  end

  def title(name, user, total) do
    active = case name do
      "Item" -> Enum.count(user.active_character.items)
      "Mod" -> Enum.count(user.active_character.mods)
    end

    [name, content_tag(:span, "(#{active}/#{total})", class: "badge badge-light")]
  end

  def th_sort(title, view, sort, prev_sort, prev_dir) do
    dir = if sort == prev_sort do
      if prev_dir == "desc", do: "asc", else: "desc"
    else
      case sort do
        _ -> "asc"
      end
    end

    link = live_link(title,
      to: Routes.live_path(LotdWeb.Endpoint, view, %{sort: sort, dir: dir}),
      class: "text-body"
    )
    color = unless sort == prev_sort, do: " text-white"
    icon = content_tag(:i, "", class: "icon-sort#{color}")

    content_tag :th, [link, icon]
  end

  def th_toggle do
    icon = content_tag :i, "", class: "icon-active"
    content_tag :th, icon, class: "text-center"
  end

  def options(map), do: Enum.into(map, %{}, fn {k, v} -> {v, k} end)
  # def options(structures), do: for s <- structures, do: content_tag(:option, s.name, value: s.id)

  def time(time), do: content_tag(:time, "", datetime: NaiveDateTime.to_iso8601(time) <> "Z")

end
