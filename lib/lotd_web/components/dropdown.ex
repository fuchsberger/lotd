defmodule LotdWeb.Components.Dropdown do
  use Phoenix.Component

  alias LotdWeb.Components.Icon
  import LotdWeb.Gettext
  import LotdWeb.Components.Link

  # prop label, :string
  # prop placement, :string, default: options: ["left", "right"]
  # slot default
  # slot trigger_element
  @doc """
    <.dropdown label="Dropdown" js_lib="alpine_js|live_view_js">
      <.dropdown_menu_item link_type="button">
        <Heroicons.Outline.home class="w-5 h-5 text-gray-500" />
        Button item with icon
      </.dropdown_menu_item>
      <.dropdown_menu_item link_type="a" to="/" label="a item" />
      <.dropdown_menu_item link_type="live_patch" to="/" label="Live Patch item" />
      <.dropdown_menu_item link_type="live_redirect" to="/" label="Live Redirect item" />
    </.dropdown>
  """
  def dropdown(assigns) do
    assigns = assigns
      |> assign_new(:class, fn -> "" end)
      |> assign_new(:button_classes, fn -> "" end)
      |> assign_new(:placement, fn -> "left" end)
      |> assign_new(:label, fn -> nil end)
      |> assign_new(:inner_block, fn -> nil end)
      |> assign_new(:section, fn -> nil end)
      |> assign_new(:trigger_element, fn -> nil end)
      |> assign_new(:extra_assigns, fn ->
          assigns_to_attributes(assigns, ~w(
            button_classes
            placement
            label
            inner_block
            section
            trigger_element
            class
          )a)
        end)

    ~H"""
    <div {@extra_assigns}
      class={"relative inline-block text-left " <> @class}
      x-data="{open: false}"
      @keydown.escape.stop="open = false"
      @click.outside="open = false"
    >
      <div>
        <button
          type="button"
          class={trigger_button_classes(@label, @trigger_element) <> @button_classes}
          aria-haspopup="true"
          @click="open = !open"
          :aria-expanded="open.toString()"
        >
          <span class="sr-only"><%= gettext "Öffne Optionen" %></span>

          <%= if @label do %>
            <%= @label %>
            <Icon.Solid.chevron_down class="w-5 h-5 ml-2 -mr-1" />
          <% end %>

          <%= if @trigger_element do %>
            <%= render_slot(@trigger_element) %>
          <% end %>

          <%= if !@label && !@trigger_element do %>
            <Icon.Solid.dots_vertical />
          <% end %>
        </button>
      </div>
      <div class={placement_class(@placement) <> " absolute z-10 w-56 rounded-md shadow-lg bg-white ring-1 ring-black ring-opacity-5 focus:outline-none"}
        role="menu"
        aria-orientation="vertical"
        aria-labelledby="options-menu"
        x-cloak
        x-show="open"
        x-transition:enter="transition ease-out duration-100"
        x-transition:enter-start="transform opacity-0 scale-95"
        x-transition:enter-end="transform opacity-100 scale-100"
        x-transition:leave="transition ease-in duration-75"
        x-transition:leave-start="transform opacity-100 scale-100"
        x-transition:leave-end="transform opacity-0 scale-95"
      >
        <%= if is_nil(@section) do %>
          <div class="py-1" role="none">
            <%= render_slot(@inner_block) %>
          </div>
        <% else %>
          <%= for section <- @sections do %>
            <div class="py-1" role="none">
              <%= render_slot(section) %>
            </div>
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end

  def dropdown_menu_item(assigns) do
    assigns = assigns
      |> assign_new(:link_type, fn -> "live_patch" end)
      |> assign_new(:inner_block, fn -> nil end)
      |> assign_new(:to, fn -> nil end)
      |> assign_new(:classes, fn -> dropdown_menu_item_classes() end)
      |> assign_new(:extra_assigns, fn ->
        assigns_to_attributes(assigns, [
          :link_type,
          :classes
        ])
      end)
    ~H"""
    <.link link_type={@link_type} to={@to} class={@classes} {@extra_assigns} @click="open=false">
      <%= if @inner_block do %>
        <%= render_slot(@inner_block) %>
      <% else %>
        <%= @label %>
      <% end %>
    </.link>
    """
  end

  defp trigger_button_classes(nil, nil), do: "flex items-center text-gray-400 rounded-full hover:text-gray-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-gray-100 focus:ring-indigo-500 "
  defp trigger_button_classes(_label, nil), do: "inline-flex justify-center w-full px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md shadow-sm hover:bg-gray-50 focus:outline-none "
  defp trigger_button_classes(_label, _trigger_element), do: ""

  def dropdown_menu_item_classes do
    "text-gray-700 hover:bg-gray-100 hover:text-gray-900 block px-4 py-2 text-sm w-full text-left"
  end

  defp placement_class("left"), do: "right-0 origin-top-right"
  defp placement_class("right"), do: "left-0 origin-top-left"
end
