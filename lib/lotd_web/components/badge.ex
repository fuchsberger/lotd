defmodule LotdWeb.Components.Badge do
  use Phoenix.Component
  import LotdWeb.Gettext

  @doc """
  ## Badge Component
  [Official TailwindCSS component](https://tailwindui.com/components/application-ui/elements/badges)

    __Usage:__
    ```heex
    <.badge
      close={[phx_click: "action", phx_value_id: 1]}
      color="gray|red|yellow|green|blue|indigo|purple|pink"
      *label="" round large dot dark
    />
    ```
  """
  def badge(assigns) do
    assigns =
      assigns
      |> assign_new(:class, fn -> "" end)
      |> assign_new(:close, fn -> false end)
      |> assign_new(:color, fn -> "gray" end)
      |> assign_new(:dark, fn -> false end)
      |> assign_new(:dot, fn -> false end)
      |> assign_new(:inner_block, fn -> nil end)
      |> assign_new(:label, fn -> "" end)
      |> assign_new(:large, fn -> false end)
      |> assign_new(:round, fn -> false end)
      |> assign_new(:optional_attributes, fn -> Map.drop(assigns,
        [:class, :close, :color, :dark, :dot, :label, :large, :round, :opts, :inner_block, :__slot__, :__changed__]) end)

    ~H"""
    <div class={class(@class, @close, @color, @dark, @large, @round)} {@optional_attributes}>
      <%= if @dot do %>
        <svg class={dot_classes(@color)} fill="currentColor" viewBox="0 0 8 8">
          <circle cx="4" cy="4" r="3" />
        </svg>
      <% end %>
      <%= if @inner_block do %>
        <%= render_slot(@inner_block) %>
      <% else %>
        <%= @label %>
      <% end %>
      <%= if @close do %>
        <button type="button" class={button_classes(@color)} {@close}>
          <span class="sr-only"><%= gettext "entfernen" %></span>
          <svg class="h-2 w-2" stroke="currentColor" fill="none" viewBox="0 0 8 8">
            <path stroke-linecap="round" stroke-width="1.5" d="M1 1l6 6m0-6L1 7" />
          </svg>
        </button>
      <% end %>
    </div>
    """
  end

  defp class(class, close, color, dark, large, round) do

    base_classes = "inline-flex items-center font-medium py-0.5"

    size_classes =
      case {close, large} do
        {false, false} -> "px-2 text-xs"
        {false, _} -> "px-2.5 text-sm"
        {_, false} -> "pl-2 pr-1 text-xs"
        {_, _} -> "pl-2.5 pr-1 text-xs"
      end

    rounded_class = if round, do: "rounded", else: "rounded-full"

    color_classes =
      if dark do
        case color do
          "gray" -> "bg-gray-900/50 text-gray-200"
          "red" -> "bg-red-900/50 text-red-200"
          "yellow" -> "bg-yellow-900/50 text-yellow-200"
          "green" -> "bg-green-900/50 text-green-200"
          "blue" -> "bg-blue-900/50 text-blue-200"
          "indigo" -> "bg-indigo-900/50 text-indigo-200"
          "purple" -> "bg-purple-900/50 text-purple-200"
          "pink" -> "bg-pink-900/50 text-pink-200"
        end
      else
        case color do
          "gray" -> "bg-gray-100 text-gray-800"
          "red" -> "bg-red-100 text-red-800"
          "yellow" -> "bg-yellow-100 text-yellow-800"
          "green" -> "bg-green-100 text-green-800"
          "blue" -> "bg-blue-100 text-blue-800"
          "indigo" -> "bg-indigo-100 text-indigo-800"
          "purple" -> "bg-purple-100 text-purple-800"
          "pink" -> "bg-pink-100 text-pink-800"
        end
      end

    Enum.join([base_classes, size_classes, rounded_class, color_classes, class], " ")
  end

  defp dot_classes(color) do
    color_class =
      case color do
        "gray" -> "text-gray-400"
        "red" -> "text-red-400"
        "yellow" -> "text-yellow-400"
        "green" -> "text-green-400"
        "blue" -> "text-blue-400"
        "indigo" -> "text-indigo-400"
        "purple" -> "text-purple-400"
        "pink" -> "text-pink-400"
      end
    "-ml-1 mr-1.5 h-2 w-2 #{color_class}"
  end

  defp button_classes(color) do
    color_class =
      case color do
        "gray" ->
          "text-gray-400 hover:bg-gray-200 hover:text-gray-500 focus:bg-gray-500 focus:text-white"
        "red" ->
          "text-red-400 hover:bg-red-200 hover:text-red-500 focus:bg-red-500 focus:text-white"
        "yellow" ->
          "text-yellow-400 hover:bg-yellow-200 hover:text-yellow-500 focus:bg-yellow-500 focus:text-white"
        "green" ->
          "text-green-400 hover:bg-green-200 hover:text-green-500 focus:bg-green-500 focus:text-white"
        "blue" ->
          "text-blue-400 hover:bg-blue-200 hover:text-blue-500 focus:bg-blue-500 focus:text-white"
        "indigo" ->
          "text-indigo-400 hover:bg-indigo-200 hover:text-indigo-500 focus:bg-indigo-500 focus:text-white"
        "purple" ->
          "text-purple-400 hover:bg-purple-200 hover:text-purple-500 focus:bg-purple-500 focus:text-white"
        "pink" ->
          "text-pink-400 hover:bg-pink-200 hover:text-pink-500 focus:bg-pink-500 focus:text-white"
      end
    "flex-shrink-0 ml-0.5 h-4 w-4 rounded-full inline-flex items-center justify-center focus:outline-none #{color_class}"
  end
end
