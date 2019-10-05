defmodule LotdWeb.ModView do
  use LotdWeb, :view

  def user_actions(conn, %Lotd.Skyrim.Mod{} = m) do
    cond do
      m.id <= 5 ->
        icon("ok-squared")
      Enum.member?(conn.assigns.character_mods, m.id) ->
        link icon("ok-squared"),
          to: Routes.mod_path(conn, :deactivate, m.id),
          method: "put",
          title: "Remove"
      true ->
        link icon("plus-squared-alt"),
          to: Routes.mod_path(conn, :activate, m.id),
          method: "put",
          title: "Activate"
    end
  end
end
