defmodule LotdWeb.ManageView do
  use LotdWeb, :view

  def save_button(changeset) do
    ico = if is_nil(changeset.data.id), do: "add", else: "edit"
    submit icon(ico, class: "text-primary"), class: "btn btn-light"
  end
end
