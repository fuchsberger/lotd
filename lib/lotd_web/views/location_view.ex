defmodule LotdWeb.LocationView do
  use LotdWeb, :view

  alias Lotd.Skyrim.Location

  def location_actions(conn, %Location{} = l) do
    [btn_edit(conn, l), btn_delete(conn, l)]
  end

  defp btn_edit(conn, location) do
    link icon("pencil"),
      to: Routes.location_path(conn, :edit, location.id),
      title: "Edit Location"
  end

  defp btn_delete(conn, location) do
    link icon("cancel", class: "has-text-danger"),
      to: Routes.location_path(conn, :delete, location.id),
      method: "delete",
      title: "Remove Location"
  end
end
