defmodule LotdWeb.Components.Table do
  use Phoenix.Component

  import LotdWeb.Components.Class

  def table(assigns) do
    assigns =
      assigns
      |> assign_new(:class, fn -> "" end)
      |> assign_new(:container_class, fn -> "" end)
      |> assign_new(:thead, fn -> nil end)
      |> assign_new(:extra_assigns, fn ->
          assigns_to_attributes(assigns, ~w(class container_class thead tbody)a)
        end)

    ~H"""
    <div class={build_class(["w-full overflow-hidden shadow ring-1 ring-black ring-opacity-5 md:rounded-lg", @container_class])}>
      <table class={build_class(["min-w-full divide-y divide-gray-300", @class])} {@extra_assigns}>
        <%= if @thead do %>
          <thead classs="bg-gray-50">
            <%= render_slot(@thead) %>
          </thead>
        <% end %>
        <tbody class="divide-y divide-gray-200 bg-white">
          <%= render_slot(@tbody) %>
        </tbody>
      </table>
    </div>
    """
  end

  def thead(assigns) do
    ~H"""
    <thead class="bg-gray-50">
      <%= render_slot(@inner_block) %>
    </thead>
    """
  end

  def tbody(assigns) do
    ~H"""
    <tbody class="divide-y divide-gray-200 bg-white">
      <%= render_slot(@inner_block) %>
    </tbody>
    """
  end

  def th(assigns) do
    assigns =
      assigns
      |> assign_new(:class, fn -> "" end)
      |> assign_new(:order, fn -> "middle" end)
      |> assign_new(:extra_assigns, fn -> assigns_to_attributes(assigns, ~w(class)a) end)

    ~H"""
    <th
      scope="col"
      class={build_class([
        order_classes(@order),
        "py-3.5 whitespace-nowrap text-sm font-semibold text-gray-900",
        @class
      ])}
      {@extra_assigns}
    >
      <%= if @inner_block do %>
        <%= render_slot(@inner_block) %>
      <% end %>
    </th>
    """
  end

  def td(assigns) do
    assigns =
      assigns
      |> assign_new(:class, fn -> "" end)
      |> assign_new(:bold, fn -> false end)
      |> assign_new(:order, fn -> "middle" end)
      |> assign_new(:extra_assigns, fn ->
        assigns_to_attributes(assigns, ~w(class weight)a)
      end)

    ~H"""
    <td
      class={build_class([
        order_classes(@order),
        td_weight_classes(@bold),
        "py-2 whitespace-nowrap text-sm",
        @class
      ])}
      {@extra_assigns}
    >
      <%= if @inner_block do %>
        <%= render_slot(@inner_block) %>
      <% end %>
    </td>
    """
  end

  defp order_classes(order) do
    case order do
      "first" -> "pl-4 pr-3 sm:pl-6"
      "last" ->  "pl-3 pr-4 sm:pr-6"
      _ -> "px-2"
    end
  end

  defp td_weight_classes(bold) do
    if bold, do: "font-medium text-gray-900", else: "text-gray-500"
  end
end
