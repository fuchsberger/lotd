defmodule LotdWeb.ViewHelpers do
  @moduledoc """
  Conveniences for all views.
  """
  use Phoenix.HTML

  # access control
  def authenticated?(conn), do: not is_nil(conn.assigns.current_user)

  # elements
  def icon(name, opts \\ [] ), do: content_tag(:i, "",
    [{:class, "icon-#{name} #{Keyword.get(opts, :class, "")}"} | Keyword.delete(opts, :class)])
end
