defmodule LotdWeb.EntryView do
  use LotdWeb, :view

  alias Lotd.Accounts.Character

  def btn_delete(changeset) do
    opts = [type: "button", class: "btn btn-danger", phx_click: "delete"]
    content_tag :button, "Delete",
      Keyword.put(opts, String.to_atom("phx_value_#{type(changeset.data)}"), changeset.data.id)
  end

  def btn_text(changeset), do: if Map.get(changeset.data, :id), do: "Update", else: "Create"

  def character?(struct), do: struct.__struct__ == Character

  def entry_class(active? \\ false) do
    "list-group-item small list-group-item-action p-1\
    d-flex justify-content-between align-items-center\
    #{if active?, do: " active"}"
  end
end
