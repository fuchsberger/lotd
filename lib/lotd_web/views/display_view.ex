defmodule LotdWeb.DisplayView do
  use LotdWeb, :view

  alias Lotd.Gallery.Display

  def display_actions(conn, %Display{} = d) do
    [btn_edit(conn, d), btn_delete(conn, d)]
  end

  def display_name(%Display{} = d) do
    if d.url, do: link(d.name, to: d.url, target: "_blank"), else: "#{d.name}"
  end

  defp btn_edit(conn, display) do
    link icon("pencil"),
      to: Routes.display_path(conn, :edit, display.id),
      title: "Edit Display"
  end

  defp btn_delete(conn, display) do
    link icon("cancel", class: "has-text-danger"),
      to: Routes.display_path(conn, :delete, display.id),
      method: "delete",
      title: "Remove Display"
  end
end
