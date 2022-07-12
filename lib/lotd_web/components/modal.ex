defmodule LotdWeb.Components.Modal do
  use Phoenix.Component

  alias LotdWeb.Components.Icon
  import LotdWeb.Gettext
  import LotdWeb.Components.{Helpers, Link}

  # prop title, :string
  # prop close_modal_target, :string
  # slot default
  def modal(assigns) do
    assigns =
      assigns
      |> assign_new(:color, fn -> "red" end)
      |> assign_new(:icon, fn -> nil end)
      |> assign_new(:footer, fn -> nil end)
      |> assign_rest(~w(color title footer icon)a)

    ~H"""
    <div {@rest} id="modal" class="relative z-10" aria-labelledby="modal-title" role="dialog" aria-modal="true">
      <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity"></div>
      <div class="fixed z-10 inset-0 overflow-y-auto">
        <div class="flex items-end sm:items-center justify-center min-h-full p-4 text-center sm:p-0">
          <div class="relative bg-white rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 w-full sm:max-w-sm sm:w-full">
            <div class="hidden sm:block absolute top-0 right-0 pt-4 pr-4">
              <.link to={@close_modal_target} class="bg-white rounded-md text-gray-400 hover:text-gray-500">
                <span class="sr-only"><%= gettext "close" %></span>
                <Icon.Outline.x class="h-6 w-6" />
              </.link>
            </div>
            <div class="bg-white px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
              <div class={if @icon, do: "sm:flex sm:items-start", else: ""}>
                <%= if @icon do %>
                  <div class="mx-auto flex-shrink-0 flex items-center justify-center h-12 w-12 rounded-full bg-red-100 sm:mx-0 sm:h-10 sm:w-10">
                    <Icon.Outline.render icon={@icon} class="h-6 w-6 text-red-600" />
                  </div>
                <% end %>
                <div class="mt-3 text-center sm:mt-0 sm:ml-4 sm:text-left">
                  <h3 class="text-lg leading-6 font-medium text-gray-900" id="modal-title"><%= @title %></h3>
                  <div class="mt-2">
                    <%= render_slot(@inner_block) %>
                  </div>
                </div>
              </div>
            </div>
            <%= if @footer do %>
              <div class="bg-gray-50 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse">
                <%= render_slot(@footer) %>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
