defmodule LotdWeb.Components.Alert do
  use Phoenix.Component

  alias LotdWeb.Components.Icon
  import LotdWeb.Gettext
  import LotdWeb.Components.Class

  @doc """
  Alert Component
    Required parameters:
      color - alert type (one of: error, info, success, warning)

    Optional parameters:
      accent - shows an accent on left side
      dismiss - allows to dismiss warning
      icon - allows to replace the default icon or hide icon (if set to nil)
      title - if provided, splits into heading and paragraph

    all other arguments are forwarded to container

    __Usage:__
    ```heex
    <.alert class="" color="error|info|success|warning" label="" accent dismiss>
    </.alert>
    ```
  """
  def alert(assigns) do
    assigns =
      assigns
      |> assign_new(:accent, fn -> nil end)
      |> assign_new(:border, fn -> nil end)
      |> assign_new(:dismiss, fn -> nil end)
      |> assign_new(:label, fn -> nil end)
      |> assign_new(:color, fn -> "info" end)
      |> assign_new(:heading, fn -> nil end)
      |> assign_new(:with_icon, fn -> nil end)
      |> assign_new(:inner_block, fn -> nil end)
      |> assign_new(:classes, fn -> alert_classes(assigns) end)
      |> assign_new(:close_button_properties, fn -> [] end)
      |> assign_new(:extra_assigns, fn ->
        assigns_to_attributes(assigns, ~w(
          accent
          dismiss
          label
          color
          heading
          with_icon
          inner_block
          classes
          class
          close_button_properties
        )a)
      end)

    ~H"""
    <%= unless label_blank?(@label, @inner_block) do %>
    <div {@extra_assigns} class={@classes} x-data="{ dismissed: false }" x-show="!dismissed" >
      <div class="flex">
        <%= if @with_icon do %>
          <div class="flex-shrink-0">
            <Icon.Solid.render icon={get_icon(@color)} class={"w-5 h-5 #{icon_color(@color)}"} />
          </div>
        <% end %>

        <div class="ml-3 flex-grow">
          <%= if @heading do %>
            <h3 class={get_heading_classes(@color)}><%= @heading %></h3>
            <div class="mt-2">
              <%= if @inner_block do %>
                <%= render_slot(@inner_block) %>
              <% else %>
                <%= @label %>
              <% end %>
            </div>
          <% else %>
            <%= if @inner_block do %>
              <%= render_slot(@inner_block) %>
            <% else %>
              <%= @label %>
            <% end %>
          <% end %>
        </div>

        <%= if @dismiss do %>
          <div class="ml-auto pl-3">
            <div class="-mx-1.5 -my-1.5">
              <button class={get_dismiss_button_classes(@color)} @click="dismissed = true" type='button' {@close_button_properties}>
                <span class="sr-only"><%= gettext("ausblenden") %></span>
                <Icon.Solid.x class="w-5 h-5" />
              </button>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    <% end %>
    """
  end

  def flash(assigns) do
    ~H"""
    <div>
      <%= if live_flash(@flash, :error) do %>
        <.alert class="mb-6" border dismiss color="error" close_button_properties={["phx-click": "lv:clear-flash", "phx-value-key": "error"]} label={live_flash(@flash, :error)} />
      <% end %>
      <%= if live_flash(@flash, :info) do %>
      <.alert class="mb-6" border dismiss color="info" close_button_properties={["phx-click": "lv:clear-flash", "phx-value-key": "info"]} label={live_flash(@flash, :info)} />
      <% end %>
      <%= if live_flash(@flash, :warning) do %>
        <.alert class="mb-6" border dismiss color="warning" close_button_properties={["phx-click": "lv:clear-flash", "phx-value-key": "warning"]} label={live_flash(@flash, :warning)} />
      <% end %>
      <%= if live_flash(@flash, :success) do %>
        <.alert class="mb-6" border dismiss color="success" close_button_properties={["phx-click": "lv:clear-flash", "phx-value-key": "success"]} label={live_flash(@flash, :success)} />
      <% end %>
    </div>
    """
  end

  defp alert_classes(opts) do
    opts = %{
      accent: opts[:accent] || nil,
      border: opts[:border] || nil,
      color: opts[:color] || "info",
      class: opts[:class] || ""
    }

    build_class([
      "p-3 text-sm",
      get_border_classes(opts.accent, opts.border),
      get_border_color_class(opts.accent, opts.border, opts.color),
      get_color_classes(opts.color),
      opts.class
    ])
  end

  @doc """
  Apply to any links inside <.alert /> elements.
  """
  def alert_link_classes(type) do
    case type do
      "error" -> "font-medium underline hover:text-red-600"
      "info" -> "font-medium underline hover:text-blue-600"
      "success" -> "font-medium underline hover:text-green-600"
      "warning" -> "font-medium underline hover:text-yellow-600"
    end
  end

  defp get_border_color_class(accent, border, color) do
    if accent || border do
      case color do
        "error" -> "border-red-400"
        "info" -> "border-blue-400"
        "success" -> "border-green-400"
        "warning" -> "border-yellow-400"
      end
    else
      ""
    end
  end

  def get_border_classes(accent, border) do
    cond do
      accent && border -> "border-r-1 border-y-1 border-l-4 shadow"
      accent -> "border-l-4"
      border -> "border shadow rounded-md"
      true -> "rounded-md"
    end
  end

  defp get_color_classes("error"), do: "bg-red-50 text-red-700"
  defp get_color_classes("info"), do: "bg-blue-50 text-blue-700"
  defp get_color_classes("success"), do: "bg-green-50 text-green-700"
  defp get_color_classes("warning"), do: "bg-yellow-50 text-yellow-700"

  defp get_dismiss_button_classes(color) do
    base = "inline-flex rounded-md p-1.5 focus:outline-none focus:ring-2 focus:ring-offset-2 "

    case color do
      "error" ->
        base <> "bg-red-50 text-red-500 hover:bg-red-100 focus:ring-offset-red-50 focus:ring-red-600"
      "info" ->
        base <> "bg-blue-50 text-blue-500 hover:bg-blue-100 focus:ring-offset-blue-50 focus:ring-blue-600"
      "success" ->
        base <> "bg-green-50 text-green-500 hover:bg-green-100 focus:ring-offset-green-50 focus:ring-green-600"
      "warning" ->
        base <> "bg-yellow-50 text-yellow-500 hover:bg-yellow-100 focus:ring-offset-yellow-50 focus:ring-yellow-600"
    end
  end

  defp get_icon("error"), do: "x_circle"
  defp get_icon("info"), do: "information_circle"
  defp get_icon("success"), do: "check_circle"
  defp get_icon("warning"), do: "exclamation"

  defp icon_color("error"), do: "text-red-400"
  defp icon_color("info"), do: "text-blue-400"
  defp icon_color("success"), do: "text-green-400"
  defp icon_color("warning"), do: "text-yellow-400"

  defp get_heading_classes("error"), do: "font-medium text-red-800"
  defp get_heading_classes("info"), do: "font-medium text-blue-800"
  defp get_heading_classes("success"), do: "font-medium text-green-800"
  defp get_heading_classes("warning"), do: "font-medium text-yellow-800"

  defp label_blank?(label, inner_block) do
    (!label || label == "") && !inner_block
  end
end
