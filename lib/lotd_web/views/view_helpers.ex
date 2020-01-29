defmodule LotdWeb.ViewHelpers do
  @moduledoc """
  Conveniences for all views.
  """
  use Phoenix.HTML

  def action_submit(changeset) do
    action = if changeset.action == :insert, do: "create", else: "update"
    String.to_atom("#{action}_#{struct_name(changeset.data)}")
  end

  def icon(name, opts \\ [] ), do: content_tag(:i, "",
    [{:class, "icon-#{name} #{Keyword.get(opts, :class, "")}"} | Keyword.delete(opts, :class)])

  def select_options(collection),
    do: [{"Please select...", nil} | Enum.map(collection, &{&1.name, &1.id})]

  def struct_name(struct), do:
    struct.__struct__
    |> Module.split()
    |> List.last()
    |> String.downcase()

  def title(changeset) do
    action = if changeset.action == :insert, do: "Create", else: "Edit"
    struct = String.capitalize(struct_name(changeset.data))
    "#{action} #{struct}"
  end
end
