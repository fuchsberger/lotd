defmodule LotdWeb.Components.Icon do
  use Phoenix.Component
  alias LotdWeb.Router.Helpers, as: Routes

  @doc """
    Icon element drawing mostly from Heroicon library (https://heroicons.com/).

    Icons are stored in `priv/static/images/icons.svg`

    __Usage:__
    ```heex
    <.icon name="solid/chevron-down" class="" />
    ```
  """
  def icon(assigns) do
    assigns = assigns
      |> assign_new(:class, fn -> "w-5 h-5" end)
      |> assign_new(:path, fn ->
          Routes.static_path(LotdWeb.Endpoint, "/images/icons.svg#" <> assigns.name)
        end)
      |> assign_new(:extra_attributes, fn ->
        Map.drop(assigns, [
          :class,
          :name,
          :path,
          :__slot__,
          :__changed__
        ])
      end)

    ~H"""
    <svg class={@class} {@extra_attributes}>
      <use href={@path}></use>
    </svg>
    """
  end
end
