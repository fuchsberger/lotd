defmodule LotdWeb.ViewHelpers do
  @moduledoc """
  Conveniences for all views.
  """
  use Phoenix.Component
  use Phoenix.HTML

  alias LotdWeb.Components.Icon

  def action_submit(changeset) do
    action = if changeset.action == :insert, do: "create", else: "update"
    String.to_atom("#{action}_#{struct_name(changeset.data)}")
  end

  def table_classes(user) do
    case user do
      %{} ->
        "dataTable has-user"

      nil ->
        "dataTable"
    end
  end

  def struct_to_string(s), do: Module.split(s.__struct__) |> List.last() |> String.downcase()

  def struct_to_atom(s), do: struct_to_string(s) |> String.to_atom()

  def struct_name(struct), do:
    struct.__struct__
    |> Module.split()
    |> List.last()
    |> String.downcase()

  def type(struct) do
    struct.__struct__
    |> to_string()
    |> String.split(".")
    |> List.last()
  end

  def sort_icon(assigns) do
    ~H"""
    <div class="group inline-flex">
      <span class="sort-icon ml-2 flex-none rounded">
        <Icon.Solid.chevron_up class="asc h-5 w-5" />
        <Icon.Solid.chevron_down class="desc h-5 w-5" />
      </span>
    </div>
    """
  end

  def static_checkbox(assigns) do
    ~H"""
    <%= if @active do %>
      <input type="checkbox" class="inline-block cursor-pointer h-4 w-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-500" checked>
    <% else %>
      <input type="checkbox" class="inline-block cursor-pointer h-4 w-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-500">
    <% end %>
    """
  end
end
