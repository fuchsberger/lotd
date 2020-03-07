defmodule LotdWeb.ManageView do
  use LotdWeb, :view

  def mod_enabled_class(character, mod) do
    if Enum.member?(character.mods, & &1.id == mod.id),
      do: "icon-active", else: "icon-inactive"
  end

  def save_button(changeset) do
    if is_nil(changeset.data.id),
      do: submit([icon("add"), " Add"], class: "btn btn-light text-primary"),
      else: submit([icon("edit"), " Update"], class: "btn btn-light text-primary")
  end

  def delete_button, do:
    content_tag :button, icon("remove", class: "text-danger"),
      class: "btn btn-light",
      data_confirm: "Are you sure you want to delete this?",
      type: "button",
      phx_click: "delete"

  def visible_items(items, search) do
    search = String.downcase(search)

    items
    |> Enum.filter(& String.contains?(String.downcase(&1.name), search))
    |> Enum.take(200)
  end
end
