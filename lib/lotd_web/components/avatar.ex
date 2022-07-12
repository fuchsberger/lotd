defmodule LotdWeb.Components.Avatar do
  use Phoenix.Component

  alias LotdWeb.Components.Icon

  # prop character, %Character{} || nil
  # prop size, :string
  def avatar(assigns) do
    assigns =
      assigns
      |> assign_new(:class, fn -> "" end)
      |> assign_new(:size, fn -> "md" end)
      |> assign_new(:extra_assigns, fn ->
          assigns_to_attributes(assigns, [:class, :size, :user])
        end)

    ~H"""
    <%= if @user && @user.avatar_url do %>
      <img
        {@extra_assigns}
        alt=""
        class={"inline-block #{size_classes((@size))} rounded-full #{@class}"}
        src={@user.avatar_url}
        title={@user.username}
        alt=""
      />
    <% else %>
      <span class={"inline-block #{size_classes(@size)} rounded-full overflow-hidden bg-gray-100 #{@class}"} {@extra_assigns}>
        <Icon.Solid.user_circle class="h-full w-full text-gray-300" alt="" />
      </span>
    <% end %>
    """
  end

  defp size_classes(size) do
    case size do
      "sm" -> "h-8 w-8"
      "md" -> "h-10 w-10"
    end
  end
end
