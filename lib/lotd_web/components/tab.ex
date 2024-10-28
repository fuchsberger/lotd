defmodule LotdWeb.Components.Tab do
  use Phoenix.Component

  # prop class, :string
  # prop full-width
  # prop variant, :string, default: "underline", options: ["underline", "pills", "bar"]
  # slot default

  def tabs(assigns) do
    assigns =
      assigns
      |> assign_new(:link_type, fn -> "live_patch" end)
      |> assign_new(:event_target, fn -> nil end)
      |> assign_new(:selected, fn -> 0 end)
      |> assign_new(:variant, fn -> "underline" end)
      |> assign_new(:class, fn -> "" end)
      |> assign_new(:extra_assigns, fn ->
        assigns_to_attributes(assigns, ~w(tabs variant class link_type)a)
      end)

    ~H"""
    <div class="hidden sm:block">
      <%= case @variant do %>
        <% "underline" -> %>
          <div class="border-b border-gray-200">
            <nav class="-mb-px flex space-x-8" aria-label="Tabs">
              <%= for {label, value} <- @tabs do %>
                <button
                  class={"whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm " <> link_class(@variant, value == @selected)}
                  type="button"
                  phx-click={@event_name}
                  phx-target={@event_target}
                  phx-value-selection={value}
                ><%= label %></button>
              <% end %>
            </nav>
          </div>
        <% "bar" -> %>
          <nav class="relative z-0 rounded-lg shadow flex divide-x divide-gray-200" aria-label="Tabs">
            <%= for {{label, value}, idx} <- Enum.with_index(@tabs) do %>
              <button
                class={"#{rounded_class(idx, Enum.count(@tabs))} group relative min-w-0 flex-1 overflow-hidden bg-white py-4 px-4 text-sm font-medium text-center hover:bg-gray-50 focus:z-10 " <> link_class(@variant, value == @selected)} l
                type="button"
                phx-click={@event_name}
                phx-target={@event_target}
                phx-value-selection={value}
              >
                <span><%= label %></span>
                <span aria-hidden="true" class={"absolute inset-x-0 bottom-0 h-0.5 " <> (if value == @selected, do: "bg-indigo-500", else: "bg-transparent")}></span>
              </button>
            <% end %>
          </nav>
        <% end %>
    </div>
    """
  end

  defp link_class("underline", true), do: "border-indigo-500 text-indigo-600"
  defp link_class("underline", false),
    do: "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"

  defp link_class("bar", true), do: "text-gray-900"
  defp link_class("bar", false), do: "text-gray-500 hover:text-gray-700"

  defp rounded_class(current, length) do
    cond do
      length == 1 -> "rounded-lg"
      current == 0 -> "rounded-l-lg"
      current == length - 1 -> "rounded-r-lg"
      true -> ""
    end
  end
end
