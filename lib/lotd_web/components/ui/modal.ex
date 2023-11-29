defmodule LotdWeb.Components.UI.Modal do
  use Phoenix.Component

  alias Phoenix.LiveView.JS

  @doc """
  Renders a modal.

  ## Examples

      <.modal id="confirm-modal">
        This is a modal.
      </.modal>
  """
  attr :id, :string, required: true
  attr :small, :boolean, default: false
  attr :show, :boolean, default: false
  slot :inner_block, required: true

  def modal(assigns) do
    ~H"""
    <div
      id={@id}
      area-labeledby={"#{@id}-title"}
      area-modal="true"
      class="relative z-50"
      data-cancel={JS.exec(%JS{}, "phx-remove")}
      phx-mounted={@show && show_modal(@id)}
      phx-remove={hide_modal(@id)}
      role="dialog"
      style="display:none;"
    >
      <div id={"#{@id}-bg"} class="fixed inset-0 bg-gray-900/80 transition-opacity" style="display:none;" />
      <div class="fixed inset-0 z-50 overflow-y-auto">
        <div class="flex min-h-full items-end justify-center p-4 text-center sm:items-center sm:p-0">
          <.focus_wrap
            id={"#{@id}-container"}
            phx-window-keydown={JS.exec("data-cancel", to: "##{@id}")}
            phx-key="escape"
            phx-click-away={JS.exec("data-cancel", to: "##{@id}")}
            class={[
              "relative transform overflow-hidden rounded-lg bg-gray-800 px-4 pb-4 pt-5 text-left shadow-xl transition-all sm:my-8 sm:w-full sm:p-6",
              @small && "sm:max-w-sm",
              !@small && "sm:max-w-lg"
            ]}
            style="display:none;"
          ><%= render_slot(@inner_block) %></.focus_wrap>
        </div>
      </div>
    </div>
    """
  end

  def show_modal(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.show(to: "##{id}")
    |> JS.show(to: "##{id}-bg", transition: {"ease-out duration-300", "opacity-0", "opacity-100"})
    |> JS.show(to: "##{id}-container", transition: {
        "ease-out duration-300",
        "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95",
        "opacity-100 translate-y-0 sm:scale-100"
      })
    |> JS.add_class("overflow-hidden", to: "body")
    |> JS.focus_first(to: "##{id}-container")
  end

  def hide_modal(js \\ %JS{}, id) do
    js
    |> JS.hide(to: "##{id}-bg", transition: {"ease-in duration-200", "opacity-100", "opacity-0"})
    |> JS.hide(to: "##{id}-container", transition: {
      "ease-in duration-200",
      "opacity-100 translate-y-0 sm:scale-100",
      "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
    })
    |> JS.hide(to: "##{id}", transition: {"block", "block", "hidden"})
    |> JS.remove_class("overflow-hidden", to: "body")
    |> JS.pop_focus()
  end
end
