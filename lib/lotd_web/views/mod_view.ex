defmodule LotdWeb.ModView do
  use LotdWeb, :view

  def btn_activate(conn, %Lotd.Skyrim.Mod{} = m, character_mod_ids) do
    if Enum.member?(character_mod_ids, m.id) do
      link icon("ok-squared"),
        to: Routes.mod_path(conn, :deactivate, m.id),
        method: "put",
        title: "Remove"

    else
      link icon("plus-squared-alt"),
        to: Routes.mod_path(conn, :activate, m.id),
        method: "put",
        title: "Activate"
    end
  end
end
