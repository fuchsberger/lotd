defmodule LotdWeb.Components.Card do
  use Phoenix.Component

  import LotdWeb.Components.Class

  # prop class, :string
  # prop variant, :string
  # slot default
  def card(assigns) do
    assigns =
      assigns
      |> assign_new(:class, fn -> "" end)
      |> assign_new(:edge, fn -> true end)
      |> assign_new(:header, fn -> nil end)
      |> assign_new(:body, fn -> nil end)
      |> assign_new(:footer, fn -> nil end)
      |> assign_new(:extra_assigns, fn ->
        assigns_to_attributes(assigns, ~w(
          class
          edge_to_edge
          header
          body
          footer
        )a)
      end)

    ~H"""
    <div {@extra_assigns} class={build_class([
      "bg-white overflow-hidden shadow",
      get_edge_classes(@edge),
      get_divider_classes(@header, @body, @footer),
      @class
    ])}>
      <%= if @header do %>
        <div class="px-4 py-5 sm:px-6">
          <%= render_slot(@header) %>
        </div>
      <% end %>
      <%= if @body do %>
        <%= for body <- @body do %>
          <div class="px-4 py-5 sm:p-6">
            <%= render_slot(body) %>
          </div>
        <% end %>
      <% end %>
      <%= if @footer do %>
        <div class={"px-4 py-4 sm:px-6"}>
          <%= render_slot(@footer) %>
        </div>
      <% end %>
      <div class="flex flex-col w-full max-w-full bg-white dark:bg-gray-800">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  defp get_edge_classes(true), do: "sm:rounded-lg"
  defp get_edge_classes(false), do: "rounded-lg"

  def get_divider_classes(h, b, f) do
    if h && b || b && f || h && f || is_list(b), do: "divide-y divide-gray-200", else: ""
  end
end
