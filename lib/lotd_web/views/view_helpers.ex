defmodule LotdWeb.ViewHelpers do
  @moduledoc """
  Conveniences for all views.
  """
  use Phoenix.HTML

  alias Lotd.Accounts.Character
  alias Lotd.Gallery.{Display, Item, Mod, Room}

  def action_submit(changeset) do
    action = if changeset.action == :insert, do: "create", else: "update"
    String.to_atom("#{action}_#{struct_name(changeset.data)}")
  end

  def icon(name, opts \\ [] ), do: content_tag(:i, "",
    [{:class, "icon-#{name} #{Keyword.get(opts, :class, "")}"} | Keyword.delete(opts, :class)])

  def select_options(collection), do: Enum.map(collection, &{&1.name, &1.id})

  def struct_name(struct) do
    case struct do
      %Character{} -> "character"
      %Display{} -> "display"
      %Item{} -> "item"
      %Mod{} -> "mod"
      %Room{} -> "room"
    end
  end

  def title(changeset) do
    action = if changeset.action == :insert, do: "Create", else: "Edit"
    struct = String.capitalize(struct_name(changeset.data))
    "#{action} #{struct}"
  end
end
