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
    <div class={build_class(["flex flex-col", @container_class])}>
      <div class="-my-2 -mx-4 overflow-x-auto sm:-mx-6 lg:-mx-8">
        <div class="inline-block min-w-full py-2 align-middle md:px-6 lg:px-8">
          <div class="overflow-hidden shadow ring-1 ring-black ring-opacity-5 md:rounded-lg">
            <table
              class={build_class(["min-w-full divide-y divide-gray-300", @class])} {@extra_assigns}
            >
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
        </div>
      </div>
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
      |> assign_new(:condensed, fn -> false end)
      |> assign_new(:order, fn -> "middle" end)
      |> assign_new(:extra_assigns, fn ->
        assigns_to_attributes(assigns, ~w(class condensed)a)
      end)

    ~H"""
    <th
      scope="col"
      class={build_class([
        th_order_classes(@order, @condensed),
        "whitespace-nowrap text-left text-sm font-semibold text-gray-900",
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
      |> assign_new(:condensed, fn -> false end)
      |> assign_new(:bold, fn -> false end)
      |> assign_new(:order, fn -> "middle" end)
      |> assign_new(:extra_assigns, fn ->
        assigns_to_attributes(assigns, ~w(class condensed weight)a)
      end)

    ~H"""
    <td
      class={build_class([
        td_order_classes(@order, @condensed),
        td_weight_classes(@bold),
        "whitespace-nowrap text-left text-sm",
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

  defp th_order_classes(order, condensed? \\ false) do
    case order do
      "first" -> (if condensed?, do: "py-2 pl-3 pr-2 sm:pl-4", else: "py-3.5 pl-4 pr-3 sm:pl-6")
      "last" ->  (if condensed?, do: "py-2 pl-2 pr-3 sm:pr-4", else: "py-3.5 pl-3 pr-4 sm:pr-6")
      _ -> (if condensed?, do: "px-2 py-3.5", else: "px-3 py-3.5")
    end
  end

  defp td_order_classes(order, condensed? \\ false) do
    case order do
      "first" -> (if condensed?, do: "py-2 pl-3 pr-2 sm:pl-4", else: "py-4 pl-4 pr-3 sm:pl-6")
      "last" ->  (if condensed?, do: "py-2 pl-2 pr-3 sm:pr-4", else: "py-4 pl-3 pr-4 sm:pr-6")
      _ -> (if condensed?, do: "px-2 py-2", else: "px-3 py-4")
    end
  end

  defp td_weight_classes(bold) do
    if bold, do: "font-medium text-gray-900", else: "text-gray-500"
  end
end
