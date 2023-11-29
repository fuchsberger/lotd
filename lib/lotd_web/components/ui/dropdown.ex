defmodule LotdWeb.Components.UI.Dropdown do
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  import LotdWeb.Components.UI.Icon

  @doc """
  Renders a dropdown.

  ## Examples

      <.dropdown id="user-menu-dropdown">
        This is a modal.
      </.dropdown>
  """
  attr :align, :atom, default: :right, values: [:left, :right]
  attr :id, :string, required: true
  attr :class, :string, default: ""
  attr :wrapper_classes, :any, default: nil

  slot :button do
    attr :class, :string
  end

  slot :link do
    attr :active, :boolean # only affects links
    attr :class, :string # only affects non-links
    attr :divider, :boolean # intended to used standalone: <:icon divider />
    attr :icon, :string # intended to be used with links
    attr :method, :atom # can be provided with href
    attr :href, :string # use either href, patch, dispatch, or none
    attr :patch, :string # use either href, patch, dispatch, or none
    attr :dispatch, :string # use either href, patch, dispatch, or none
    attr :target, :string # can be provided with dispatch
  end

  def dropdown(assigns) do
    ~H"""
    <div class={["relative", @wrapper_classes]}>
      <div>
        <button id={"#{@id}-button"} class={@button |> List.first() |> Map.get(:class)} area-expanded="false" area-haspopup="true" phx-click={open_dropdown(@id)}>
          <%= render_slot(@button) %>
        </button>
      </div>
      <div id={@id} class={[
        "absolute z-10 mt-2 w-48 rounded-md border border-gray-700 bg-gray-800 py-1 shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none",
        @align == :left && "left-0 origin-top-left",
        @align == :right && "right-0 origin-top-right",
        @class
      ]} role="menu" aria-orientation="vertical" aria-labelledby={"#{@id}-button"} tabindex="-1" style="display:none;" phx-click-away={close_dropdown(@id)}>
        <%= for {link, idx} <- Enum.with_index(@link) do %>
          <hr class="my-1 bt-1 border-gray-700" :if={Map.get(link, :divider, false)} />
          <div
            :if={!Map.get(link, :divider, false) && !Map.get(link, :href) && !Map.get(link, :patch) && !Map.get(link, :dispatch)}
            class={Map.get(link, :class)}
          ><%= render_slot(link) %></div>
          <.link
            :if={!Map.get(link, :divider, false) && (Map.get(link, :href) || Map.get(link, :patch) || Map.get(link, :dispatch))}
            class={[
              "block px-4 py-2 text-sm text-gray-300 0",
              !Map.get(link, :icon) && "block",
              Map.get(link, :icon) && "group flex items-center",
              Map.get(link, :active, false) && "bg-gray-700",
              !Map.get(link, :active, false) && "hover:bg-gray-700",
            ]}
            href={Map.get(link, :href)}
            patch={Map.get(link, :patch)}
            target={Map.get(link, :target, "_self")}
            method={Map.get(link, :method, :get)}
            role="menuitem"
            tabindex={idx}
            phx-click={if Map.get(link, :dispatch),
            do: close_dropdown(@id) |> JS.dispatch(link.dispatch),
            else: close_dropdown(@id)}
          >
          <.icon name={Map.get(link, :icon)} :if={Map.get(link, :icon)} class="mr-3 h-5 w-5 text-gray-400 group-hover:text-gray-100" />
          <%= render_slot(link) %>
        </.link>
        <% end %>
      </div>
    </div>
    """
  end

  def open_dropdown(id) when is_binary(id) do
    %JS{}
    |> JS.set_attribute({"area-expanded", "true"}, to: "##{id}-button")
    |> JS.show(to: "##{id}", transition: {
      "transition ease-out duration-200",
      "transform opacity-0 scale-95",
      "transform opacity-100 scale-100"
    })
  end

  def close_dropdown(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.set_attribute({"area-expanded", "false"}, to: "##{id}-button")
    |> JS.hide(to: "##{id}", transition: {
      "transition ease-in duration-75",
      "transform opacity-100 scale-100",
      "transform opacity-0 scale-95"
    })
  end
end
