defmodule LotdWeb.ErrorHelpers do
  @moduledoc """
  Conveniences for translating and building error messages.
  """

  use Phoenix.HTML

  def form_class(submitted) do
    if submitted, do: "was-validated"
  end

  def control_class(form, field) do
    if Keyword.has_key?(form.source.errors, field),
      do: "form-control invalid", else: "form-control valid"
  end

  def error_class(form, field) do
    Enum.map(Keyword.get_values(form.errors, field), fn _error -> " is-invalid" end)
  end

  @doc """
  Generates tag for inlined form input errors.
  """
  def error_tag(form, field) do
    Enum.map(Keyword.get_values(form.source.errors, field), fn error ->
      content_tag(:small, translate_error(error), class: "form-text text-muted")
    end)
  end

  def error_map(changeset) do
    changeset.errors
    |> Enum.map(fn error ->
        {field, {error, _  }} = error
        {field, error}
      end)
    |> Enum.into(%{})
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate "is invalid" in the "errors" domain
    #     dgettext("errors", "is invalid")
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # Because the error messages we show in our forms and APIs
    # are defined inside Ecto, we need to translate them dynamically.
    # This requires us to call the Gettext module passing our gettext
    # backend as first argument.
    #
    # Note we use the "errors" domain, which means translations
    # should be written to the errors.po file. The :count option is
    # set by Ecto and indicates we should also apply plural rules.
    if count = opts[:count] do
      Gettext.dngettext(LotdWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(LotdWeb.Gettext, "errors", msg, opts)
    end
  end
end
