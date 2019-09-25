defmodule LotdWeb.ViewHelpers do
  @moduledoc """
  Conveniences for all views.
  """

  use Phoenix.HTML

  def icon(name), do: raw "<span class='icon'><i class='icon-#{name}'></i></span>"
end
