defmodule LotdWeb.ManageView do
  use LotdWeb, :view

  def save_button(changeset) do
    ico = if is_nil(changeset.data.id), do: "add", else: "edit"
    submit icon(ico, class: "text-primary"), class: "btn btn-light"
  end

  def delete_button, do: content_tag :button, icon("remove", class: "text-danger"),
    class: "btn btn-light",
    type: "button",
    phx_click: "delete"

  def visible_items(items, search) do
    search = String.downcase(search)

    items
    |> Enum.filter(& String.contains?(String.downcase(&1.name), search))
    |> Enum.take(200)
  end
end
