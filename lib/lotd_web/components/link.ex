defmodule LotdWeb.Components.Link do
  use Phoenix.Component

  @doc """
    Universal link element for normal links as well as live navigation.

    __Usage:__
    ```heex
    <.link link_type="a | live_patch | live_redirect" to="/" class="" label="" />
    ```
  """
  def link(assigns) do
    assigns = assigns
      |> assign_new(:class, fn -> "" end)
      |> assign_new(:link_type, fn -> "live_patch" end)
      |> assign_new(:label, fn -> nil end)
      |> assign_new(:inner_block, fn -> nil end)
      |> assign_new(:extra_attributes, fn ->
        Map.drop(assigns, [
          :class,
          :link_type,
          :type,
          :inner_block,
          :label,
          :__slot__,
          :__changed__
        ])
      end)

    ~H"""
    <%= case @link_type do %>
      <% "a" -> %>
        <%= Phoenix.HTML.Link.link [to: @to, class: @class] ++ Map.to_list(@extra_attributes) do %>
          <%= if @inner_block do %>
            <%= render_slot(@inner_block) %>
          <% else %>
            <%= @label %>
          <% end %>
        <% end %>
      <% "live_patch" -> %>
        <%= live_patch [
          to: @to,
          class: @class,
        ] ++ Enum.to_list(@extra_attributes) do %>
          <%= if @inner_block do %>
            <%= render_slot(@inner_block) %>
          <% else %>
            <%= @label %>
          <% end %>
        <% end %>
      <% "live_redirect" -> %>
        <%= live_redirect [
          to: @to,
          class: @class,
        ] ++ Enum.to_list(@extra_attributes) do %>
          <%= if @inner_block do %>
            <%= render_slot(@inner_block) %>
          <% else %>
            <%= @label %>
          <% end %>
        <% end %>
    <% end %>
    """
  end
end
