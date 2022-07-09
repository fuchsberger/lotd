defmodule LotdWeb.Components.Icon.Custom do
  @moduledoc """
  Icon name can be the function or passed in as a type eg.
  <Icon.Lotd.Logo class="w-5 h-5" />
  <Icon.Lotd.render icon="home" class="w-5 h-5" />
  """
  use Phoenix.Component

  def render(%{icon: icon_name} = assigns) when is_atom(icon_name) do
    apply(__MODULE__, icon_name, [assigns])
  end

  def render(%{icon: icon_name} = assigns) do
    icon_name = String.to_existing_atom(icon_name)
    apply(__MODULE__, icon_name, [assigns])
  end

  def avatar_placeholder(assigns) do
    assigns =
      assigns
      |> assign_new(:class, fn -> "h-5 w-5" end)
      |> assign_new(:extra_attributes, fn ->
        assigns_to_attributes(assigns, [:class])
      end)

    ~H"""
    <svg class={@class} {@extra_attributes} xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
      <path d="M24 20.993V24H0v-2.996A14.977 14.977 0 0112.004 15c4.904 0 9.26 2.354 11.996 5.993zM16.002 8.999a4 4 0 11-8 0 4 4 0 018 0z" />
    </svg>
    """
  end
end
