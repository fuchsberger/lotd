defmodule LotdWeb.Components.Alert do
  use LotdWeb, :ui_component

  @doc """
  ## Examples

  ```heex
  <.alert type={:error} text="" />
  <.alert type={:info} text="" dismiss={false} />

  <.alert type={:warning}>
  </.alert>
  ```
  """

  attr :dismiss, :boolean, default: true
  attr :link_label, :string, default: nil
  attr :link_path, :string, default: nil
  attr :rounded, :boolean, default: true
  attr :shadow, :boolean, default: false
  attr :title, :string, default: nil
  attr :text, :string, required: true
  attr :type, :atom, values: [:error, :info, :warning]
  attr :rest, :global

  slot :actions
  slot :description

  def alert(assigns) do
    ~H"""
    <div class={classes([rounded_class(@rounded), shadow_class(@shadow), bg_class(@type), "p-4"])} {extra_attrs(@rest, @dismiss)}>
      <div class="flex">
        <div class="flex-shrink-0">
          <%= case @type do %>
            <% :error -> %>
              <Heroicons.x_circle mini class="h-5 w-5 text-red-400" />
            <% :info -> %>
              <Heroicons.information_circle mini class="h-5 w-5 text-blue-400" />
            <% :warning -> %>
              <Heroicons.exclamation_triangle mini class="h-5 w-5 text-yellow-400" />
          <% end %>
        </div>

        <%= if @link_label && @link_path do %>
          <div class="ml-3 flex-1 md:flex md:justify-between">
            <p class={"text-sm #{text_class(@type)}"}><%= @text %></p>
            <p class="mt-3 text-sm md:mt-0 md:ml-6">
              <a href={@link_path} class={"whitespace-nowrap font-medium #{link_class(@type)}"}>
                <%= @link_label %>
                <span aria-hidden="true"> &rarr;</span>
              </a>
            </p>
          </div>
        <% else %>
          <div class="ml-3">
            <%= if is_nil(render_slot(@description)) do %>
              <p class={"text-sm font-medium #{text_class(@type)}"}><%= @text %></p>
            <% else %>
              <h3 class={"text-sm font-medium #{text_class(@type)}"}><%= @text %></h3>
              <div class={"mt-2 text-sm #{desc_class(@type)}"}>
                <%= render_slot(@description) %>
              </div>
              <%= unless is_nil(render_slot(@actions)) do %>
                <div class="mt-4">
                  <div class="-mx-2 -my-1.5 flex">
                    <%= render_slot(@actions) %>
                  </div>
                </div>
              <% end %>
            <% end %>
          </div>
          <%= if @dismiss do %>
            <div class="ml-auto pl-3">
              <div class="-mx-1.5 -my-1.5">
                <button type="button" class={"inline-flex rounded-md p-1.5 focus:outline-none focus:ring-2 focus:ring-offset-2 #{button_classes(@type)}"} @click="show = false">
                  <span class="sr-only"><%= gettext "ausblenden" %></span>
                  <Heroicons.x_mark mini class="h-5 w-5" />
              </button>
              </div>
            </div>
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end

  def alert_action_classes(:error), do: "rounded-md bg-red-50 px-2 py-1.5 text-sm font-medium text-red-800 hover:bg-red-100 focus:outline-none focus:ring-2 focus:ring-red-600 focus:ring-offset-2 focus:ring-offset-red-50"

  defp extra_attrs(rest, dismiss) do
    if dismiss do
      Map.merge(rest, %{x_data: "{show: true}", x_cloak: true, x_show: "show"})
    else
      rest
    end
  end

  defp rounded_class(false), do: ""
  defp rounded_class(true), do: "rounded-md border"

  defp shadow_class(false), do: nil
  defp shadow_class(true), do: "shadow-lg"

  defp bg_class(:error), do: "bg-red-50 border-red-400"
  defp bg_class(:info), do: "bg-blue-50 border-blue-400"
  defp bg_class(:warning), do: "bg-yellow-50 border-yellow-400"

  defp text_class(:error), do: "text-red-800"
  defp text_class(:info), do: "text-blue-800"
  defp text_class(:warning), do: "text-yellow-800"

  defp desc_class(:error), do: "text-red-700"
  defp desc_class(:info), do: "text-blue-700"
  defp desc_class(:warning), do: "text-yellow-700"

  defp link_class(:error), do: "text-red-700 hover:text-red-600"
  defp link_class(:info), do: "text-blue-700 hover:text-blue-600"
  defp link_class(:warning), do: "text-yellow-700 hover:text-yellow-600"

  defp button_classes(:error),
    do: "bg-red-50 text-red-500 hover:bg-red-100 focus:ring-red-600 focus:ring-offset-red-50"

  defp button_classes(:info),
    do: "bg-blue-50 text-blue-500 hover:bg-blue-100 focus:ring-blue-600 focus:ring-offset-blue-50"

  defp button_classes(:warning),
    do: "bg-yellow-50 text-yellow-500 hover:bg-yellow-100 focus:ring-yellow-600 focus:ring-offset-yellow-50"
end
