defmodule LotdWeb.Components.Button do
  use Phoenix.Component

  alias LotdWeb.Components.Icon
  import LotdWeb.Components.Link

  # prop class, :string
  # prop color, :string, options: ["primary", "secondary", "info", "success", "warning", "danger", "gray"]
  # prop link_type, :string, options: ["button", "a", "live_patch", "live_redirect"]
  # prop label, :string
  # prop size, :string
  # prop variant, :string
  # prop to, :string
  # prop disabled, :boolean, default: false
  # slot default
  def button(assigns) do
    assigns =
      assigns
      |> assign_new(:link_type, fn -> "button" end)
      |> assign_new(:inner_block, fn -> nil end)
      |> assign_new(:size, fn -> "md" end)
      |> assign_new(:disabled, fn -> false end)
      |> assign_new(:leading_icon, fn -> nil end) # solid variant only
      |> assign_new(:trailing_icon, fn -> nil end) # solid variant only
      |> assign_new(:extra_assigns, fn -> get_extra_assigns(assigns) end)
      |> assign_new(:classes, fn -> button_classes(assigns) end)
      |> assign_new(:class, fn -> "" end)
      |> assign_new(:to, fn -> nil end)

    ~H"""
    <.link to={@to} link_type={@link_type} class={@classes} disabled={@disabled} {@extra_assigns}>
      <%= if @leading_icon do %>
        <Icon.Solid.render icon={@leading_icon} class={leading_icon_css(@size, @color)} />
      <% end %>
      <%= if @inner_block do %>
        <%= render_slot(@inner_block) %>
      <% else %>
        <%= @label %>
      <% end %>
      <%= if @trailing_icon do %>
        <Icon.Solid.render icon={@trailing_icon} class={trailing_icon_css(@size, @color)} />
      <% end %>
    </.link>
    """
  end

  # prop class, :string
  # prop color, :string, options: ["primary", "secondary", "info", "success", "warning", "danger", "gray"]
  # prop link_type, :string, options: ["button", "a", "live_patch", "live_redirect"]
  # prop label, :string
  # prop size, :string
  # prop variant, :string
  # prop to, :string
  # prop loading, :boolean, default: false
  # prop disabled, :boolean, default: false
  # slot default
  # def icon_button(assigns) do
  #   assigns =
  #     assigns
  #     |> assign_new(:link_type, fn -> "button" end)
  #     |> assign_new(:inner_block, fn -> nil end)
  #     |> assign_new(:loading, fn -> false end)
  #     |> assign_new(:size, fn -> "sm" end)
  #     |> assign_new(:disabled, fn -> false end)
  #     |> assign_new(:extra_assigns, fn -> get_extra_assigns(assigns) end)
  #     |> assign_new(:class, fn -> "" end)
  #     |> assign_new(:to, fn -> nil end)
  #     |> assign_new(:color, fn -> "gray" end)

  #   ~H"""
  #   <.link
  #     to={@to}
  #     link_type={@link_type}
  #     class={build_class(
  #       [
  #         "rounded-full p-2 inline-block",
  #         get_disabled_classes(@disabled),
  #         get_icon_button_background_color_classes(@color),
  #         get_icon_button_color_classes(@color),
  #         @class
  #       ])}
  #     disabled={@disabled}
  #     {@extra_assigns}
  #   >
  #     <%= if @loading do %>
  #       <Loading.spinner show={true} size_class={get_spinner_size_classes(@size)} />
  #     <% else %>
  #       <Icon.Solid.render icon={@icon} class={build_class(
  #         [
  #           get_icon_button_size_classes(@size)
  #         ])}/>
  #     <% end %>
  #   </.link>
  #   """
  # end

  defp button_classes(opts) do
    opts = %{
      size: opts[:size] || "md",
      variant: opts[:variant] || "solid",
      color: opts[:color] || "primary",
      loading: opts[:loading] || false,
      disabled: opts[:disabled] || false,
      icon: opts[:icon] || false,
      user_added_classes: opts[:class] || ""
    }

    color_css =
      case opts[:color] do
        "primary" ->
          "border border-transparent shadow-sm text-white bg-indigo-600 hover:bg-indigo-700"
        "secondary" ->
          "border border-transparent text-indigo-700 bg-indigo-100 hover:bg-indigo-200"
        "white" ->
          "border border-gray-300 shadow-sm text-gray-700 bg-white hover:bg-gray-50"
        "red" ->
          "border border-transparent text-red-700 bg-red-100 hover:bg-red-200"
      end

    size_css =
      case opts[:size] do
        "xs" -> "text-xs px-2.5 py-1.5"
        "sm" -> "text-sm leading-4 px-3 py-2"
        "md" -> "text-sm px-4 py-2"
        "lg" -> "text-base px-4 py-2"
        "xl" -> "text-base px-6 py-3"
      end

    rounded_css =
      case {opts[:size], opts[:variant]} do
        {_, "rounded"} -> "rounded-full"
        {"xs", _} -> "rounded"
        {_, _} -> "rounded-md"
      end

    disabled_css =
      if opts[:disabled] do
        "disabled cursor-not-allowed opacity-50"
      else
        ""
      end

    [
      "inline-flex items-center justify-center font-medium focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500",
      size_css,
      color_css,
      rounded_css,
      disabled_css,
      opts.user_added_classes
    ]
    |> Enum.join(" ")
  end

  defp get_extra_assigns(assigns) do
    assigns_to_attributes(assigns, [
      :disabled,
      :link_type,
      :size,
      :variant,
      :color,
      :icon,
      :class,
      :to
    ])
  end

  defp leading_icon_css(size, color) do
    size_css =
      case size do
        #xs not supported
        "sm" -> "-ml-0.5 mr-2 h-4 w-4"
        "md" -> "-ml-1 mr-2 h-5 w-5"
        _lg_or_xl -> "-ml-1 mr-3 h-5 w-5"
      end

    color_css = if color == "white", do: " text-gray-400", else: ""
    "#{size_css}#{color_css}"
  end

  defp trailing_icon_css(size, color) do
    size_css =
      case size do
        #xs not supported
        "sm" -> "ml-2 -mr-0.5 h-4 w-4"
        "md" -> "ml-2 -mr-1 h-5 w-5"
        _lg_or_xl -> "ml-3 -mr-1 h-5 w-5"
      end

    color_css = if color == "white", do: " text-gray-400", else: ""

    "#{size_css}#{color_css}"
  end

  # def details_close_button(assigns) do
  #   ~H"""
  #   <.button phx-click="close-details" variant="close">
  #     <Icon.Solid.x />
  #   </.button>
  #   """
  # end
end
