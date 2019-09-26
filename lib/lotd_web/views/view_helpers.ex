defmodule LotdWeb.ViewHelpers do
  @moduledoc """
  Conveniences for all views.
  """

  use Phoenix.HTML

  def icon(name, opts \\ [] ) do
    class = Keyword.get(opts, :class, "")
    raw "<span class='icon #{class}'><i class='icon-#{name}'></i></span>"
  end

  def time(time) do
    content_tag :time, "", datetime: NaiveDateTime.to_iso8601(time) <> "Z"
  end
end
