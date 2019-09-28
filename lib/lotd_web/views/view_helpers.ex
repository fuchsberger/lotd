defmodule LotdWeb.ViewHelpers do
  @moduledoc """
  Conveniences for all views.
  """

  use Phoenix.HTML

  def authenticated?(conn), do: conn.assigns.current_user
  def moderator?(conn), do: authenticated?(conn) && conn.assigns.current_user.moderator
  def admin?(conn), do: authenticated?(conn) && conn.assigns.current_user.admin

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
