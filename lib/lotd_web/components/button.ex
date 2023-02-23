defmodule LotdWeb.Components.Button do
  use LotdWeb, :ui_component

  import LotdWeb.Components.Icon, only: [icon: 1]

  @doc """
  ## Examples

  ```heex
  <.button color={:primary}></.button>
  ```
  """
  attr :class, :string, default: ""
  attr :color, :string, default: "unstyled" # unstyled, primary, secondary, white
  attr :disabled, :boolean, default: false
  attr :group_placement, :string, default: nil,
    doc: "For use inside a button group. Options: first, last, inner, nil"
  attr :size, :string, default: "md" # xs, sm, md, lg, xl
  attr :type, :string, default: "button" # button submit or link
  attr :variant, :string, default: nil # leading, trailing or circular, rounded
  attr :icon, :atom, default: nil, doc: "name of a heroicon (mini variant)"
  attr :rest, :global, default: %{}

  slot :inner_block

  def button(assigns) do
    ~H"""
    <%= if @type == "link" do %>
      <.link class={button_classes(@class, @color, @disabled, @group_placement, @size, @variant)} {@rest}>
        <%= if @icon && (@variant == "leading" || @variant == "circular") do %>
          <.icon name={@icon} class={icon_classes(@variant, @size)} />
        <% end %>

        <%= render_slot(@inner_block) %>

        <%= if @icon && @variant == "trailing" do %>
          <.icon name={@icon} class={icon_classes(@variant, @size)} />
        <% end %>
      </.link>
    <% else %>
      <button type={@type} class={button_classes(@class, @color, @disabled, @group_placement, @size, @variant)} {@rest}>
        <%= if @icon && (@variant == "leading" || @variant == "circular") do %>
          <.icon name={@icon} class={icon_classes(@variant, @size)} />
        <% end %>

        <%= render_slot(@inner_block) %>

        <%= if @icon && @variant == "trailing" do %>
          <.icon name={@icon} class={icon_classes(@variant, @size)} />
        <% end %>
      </button>
    <% end %>
    """
  end

  defp button_classes(extra_classes, color, disabled, group_placement, size, variant) do
    group_placement_css =
      case group_placement do
        "first" -> "relative !px-2"
        "inner" -> "relative -ml-px !px-2"
        "last" -> "relative -ml-px !px-2"
        nil -> ""
      end

    base_css =
      unless color == "unstyled" do
        "inline-flex items-center"
      else
        ""
      end

    rounded_css =
      cond do
        color == "unstyled" -> ""
        group_placement == "first" -> "rounded-l-md"
        group_placement == "inner" -> ""
        group_placement == "last" -> "rounded-r-md"
        variant == "circular" || variant == "rounded" -> "rounded-full"
        size == "xs" -> "rounded"
        true -> "rounded-md"
      end

    border_css =
      case color do
        "unstyled" -> ""
        "white" -> "border border-gray-300 bg-white"
        _ -> "border border-transparent"
      end

    background_css =
      case color do
        "unstyled" -> ""
        "white" -> "bg-white"
        "secondary" -> "bg-indigo-100"
        "primary" -> "bg-indigo-600"
      end

    size_css =
      case {color, size, variant} do
        {"unstyled", _, _} -> ""
        {_, "xs", "circular"} -> "p-1"
        {_, "xs", "rounded"} -> "px-3 py-1.5 text-xs"
        {_, "xs", _} -> "px-2.5 py-1.5 text-xs"
        {_, "sm", "circular"} -> "p-1.5"
        {_, "sm", "rounded"} -> "px-3.5 py-2 text-sm leading-4"
        {_, "sm", _} -> "px-3 py-2 text-sm leading-4"
        {_, "md", "circular"} -> "p-2"
        {_, "md", _} -> "px-4 py-2 text-sm"
        {_, "lg", "circular"} -> "p-2"
        {_, "lg", "rounded"} -> "px-5 py-2 text-base"
        {_, "lg", _} -> "px-4 py-2 text-base"
        {_, "xl", "circular"} -> "p-3"
        {_, "xl", _} -> "px-6 py-3 text-base"
      end

    font_weight_css =
      case {color, variant} do
        {"unstyled", _} -> ""
        {_, "circular"} -> ""
        {_, _} -> "font-medium"
      end

    text_css =
      case color do
        "unstyled" -> ""
        "white" -> "text-gray-700 shadow-sm hover:bg-gray-50"
        "secondary" -> "text-indigo-700 hover:bg-indigo-200"
        "primary" -> "text-white shadow-sm hover:bg-indigo-700"
      end

    focus_css =
      cond do
        color == "unstyled" ->
          ""

        is_nil(group_placement) ->
          "focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"

        true ->
          "focus:z-10 focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500"
      end

    disabled_css =
      if disabled do
        "disabled cursor-not-allowed opacity-50"
      else
        ""
      end

    [
      group_placement_css,
      base_css,
      rounded_css,
      border_css,
      background_css,
      size_css,
      font_weight_css,
      text_css,
      focus_css,
      disabled_css,
      extra_classes
    ]
    |> Enum.reject(& &1 == "")
    |> Enum.join(" ")
  end

  defp icon_classes(variant, size) do
    case {variant, size} do
      {"leading", "sm"} -> "-ml-0.5 mr-2 h-4 w-4"
      {"leading", "md"} -> "-ml-1 mr-2 h-5 w-5"
      {"leading", "lg"} -> "-ml-1 mr-3 h-5 w-5"
      {"leading", "xl"} -> "-ml-1 mr-3 h-5 w-5"
      {"trailing", "sm"} -> "ml-2 -mr-0.5 h-4 w-4"
      {"trailing", "md"} -> "ml-2 -mr-1 h-5 w-5"
      {"trailing", "lg"} -> "ml-3 -mr-1 h-5 w-5"
      {"trailing", "xl"} -> "ml-3 -mr-1 h-5 w-5"
      {"circular", "xs"} -> "h-5 w-5"
      {"circular", "sm"} -> "h-5 w-5"
      {"circular", "md"} -> "h-5 w-5"
      {"circular", "lg"} -> "h-6 w-6"
      {"circular", "xl"} -> "h-6 w-6"
    end
  end
end
