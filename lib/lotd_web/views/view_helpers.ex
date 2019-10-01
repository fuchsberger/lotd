defmodule LotdWeb.ViewHelpers do
  @moduledoc """
  Conveniences for all views.
  """

  use Phoenix.HTML

  def authenticated?(conn), do: not is_nil(conn.assigns.current_user)
  def moderator?(conn), do: authenticated?(conn) && conn.assigns.current_user.moderator
  def admin?(conn), do: authenticated?(conn) && conn.assigns.current_user.admin

  def active_character_id(conn),
    do: authenticated?(conn) && conn.assigns.current_user.active_character_id

  def character_item_ids(conn) do
    if active_character_id(conn),
      do: Enum.map(conn.assigns.current_user.active_character.items, fn i -> i.id end),
      else: []
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

  def time(time) do
    content_tag :time, "", datetime: NaiveDateTime.to_iso8601(time) <> "Z"
  end

end
