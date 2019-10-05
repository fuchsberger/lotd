defmodule LotdWeb.ControllerHelpers do

  import LotdWeb.ViewHelpers, only: [authenticated?: 1]

  def user(conn), do: conn.assigns.current_user

  def character(conn), do: authenticated?(conn) && conn.assigns.current_user.active_character

end
