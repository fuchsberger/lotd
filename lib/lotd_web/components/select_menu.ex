defmodule LotdWeb.Components.SelectMenu do
  use Phoenix.Component

  alias LotdWeb.Components.Icon
  import LotdWeb.Components.Link

  # prop class, :string
  # prop selected, :integer, default: 0
  # prop options, :list of {label, path} tuples, default: []

  # slot default

  def select_menu(assigns) do
    assigns =
      assigns
      |> assign_new(:id, fn -> "select_menu_#{Ecto.UUID.generate()}" end)
      |> assign_new(:class, fn -> "" end)
      |> assign_new(:label, fn -> nil end)
      |> assign_new(:selected, fn -> 0 end)
      |> assign_new(:extra_assigns, fn ->
          assigns_to_attributes(assigns, ~w(class event_name event_target label options selected)a)
        end)

    ~H"""
    <div class={@class} {@extra_assigns}>
      <%= if @label do %>
        <label id={@id} class="block text-sm font-medium text-gray-700 mb-1"><%= @label %></label>
      <% end %>
      <div class="relative" x-data="{open: false, highlighted: null}" @click.outside="open = false">
        <button type="button" class="bg-white relative w-full border border-gray-300 rounded-md shadow-sm pl-3 pr-10 py-2 text-left cursor-default focus:outline-none focus:ring-1 focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm" aria-haspopup="listbox" aria-expanded="true" aria-labelledby="listbox-label" @click="open = !open">
          <span class="block truncate"><%= selected_label(@options, @selected) %></span>
          <span class="absolute inset-y-0 right-0 flex items-center pr-2 pointer-events-none">
            <Icon.Solid.selector class="h-5 w-5 text-gray-400" />
          </span>
        </button>

        <ul
          class="absolute z-10 mt-1 w-full bg-white shadow-lg max-h-60 rounded-md py-1 text-base ring-1 ring-black ring-opacity-5 overflow-auto focus:outline-none sm:text-sm" tabindex="-1"
          role="listbox"
          aria-labelledby="listbox-label"
          aria-activedescendant="listbox-option-3"
          x-show="open"
          x-transition:leave="transition ease-in duration-100"
          x-transition:leave-start="opacity-100"
          x-transition:leave-end="opacity-0"
          @mouseleave="highlighted = null"
        >
          <%= for {label, value} <- @options do %>
            <li
              class="select-none relative py-2 pl-3 pr-9"
              :class={"highlighted == #{value} ? \"text-white bg-indigo-600\" : \"text-gray-900\""}
              role="option"
              @mouseenter={"highlighted = #{value}"}
            >
              <.link
                class="cursor-default w-full text-left"
                link_type="button"
                phx-click={@event_name}
                phx-target={@event_target}
                phx-value-selection={value}
                @click="open = !open"
              >
                <span class={"#{if @selected == value, do: "font-semibold", else: "font-normal"} block truncate"}><%= label %></span>

                <%= if @selected == value do %>
                  <span class="absolute inset-y-0 right-0 flex items-center pr-4" :class={"highlighted == #{value} ? \"text-white\" : \"text-indigo-600\""}>
                    <Icon.Solid.check class="h-5 w-5" />
                  </span>
                <% end %>
              </.link>
            </li>
          <% end %>
        </ul>
      </div>
    </div>
    """
  end

  defp selected_label(options, selected) do
    Enum.find(options, & elem(&1, 1) == selected) |> elem(0)
  end
end
