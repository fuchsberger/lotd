defmodule LotdWeb.ViewHelpers do
  @moduledoc """
  Conveniences for all views.
  """
  use Phoenix.HTML

  alias Phoenix.HTML.Form

  def action_submit(changeset) do
    action = if changeset.action == :insert, do: "create", else: "update"
    String.to_atom("#{action}_#{struct_name(changeset.data)}")
  end

  def text_input(form, field, opts \\ []) do
    Form.text_input(form, field, opts ++ Form.input_validations(form, field))
  end

  def url_input(form, field, opts \\ []) do
    Form.url_input(form, field, opts ++ Form.input_validations(form, field))
  end

  def select(form, field, options, opts \\ []) do
    Form.select(form, field, options, opts ++ Form.input_validations(form, field))
  end

  def select_options(collection),
    do: [{"Please select...", nil} | Enum.map(collection, &{&1.name, &1.id})]


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
end
