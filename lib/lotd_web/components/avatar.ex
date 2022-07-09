defmodule LotdWeb.Components.Avatar do
  use Phoenix.Component

  alias LotdWeb.Components.Icon
  alias LotdWeb.Router.Helpers, as: Routes

  # prop character, %Character{} || nil
  # prop size, :string
  def avatar(assigns) do
    assigns =
      assigns
      |> assign_new(:class, fn -> "" end)
      |> assign_new(:size, fn -> "sm" end)
      |> assign_new(:extra_assigns, fn ->
          assigns_to_attributes(assigns, [:character, :class, :size])
        end)

    ~H"""
    <%= if @character do %>
      <%= if @character.avatar do %>
        <img
          {@extra_assigns}
          alt=""
          class={"inline-block #{size_classes((@size))} rounded-full #{@class}"}
          src={Routes.static_path(LotdWeb.Endpoint, "/images/avatars/" <> @character.avatar)}
          title={@character.name}
        />
      <% else %>
        <span
          {@extra_assigns}
          class={"inline-flex items-center justify-center #{size_classes(@size)} rounded-full bg-gray-500 #{@class}"}
          title={@character.name}
        >
          <span class={"#{text_size_class(@size)} font-medium leading-none text-white"}><%= initials(@character.name) %></span>
        </span>
      <% end %>
    <% else %>
      <span class={"inline-block #{size_classes(@size)} rounded-full overflow-hidden bg-gray-100 #{@class}"} {@extra_assigns}>
        <Icon.Custom.avatar_placeholder class="h-full w-full text-gray-300" />
      </span>
    <% end %>
    """
  end

  def avatar_group(assigns) do
    assigns =
      assigns
      |> assign_new(:class, fn -> "" end)
      |> assign_new(:size, fn -> "sm" end)
      |> assign_new(:extra_assigns, fn ->
        assigns_to_attributes(assigns, ~w(characters class size)a)
      end)

    ~H"""
    <div {@extra_assigns} class={"flex #{stacked_class(@size)} overflow-hidden #{@class}"}>
      <%= for c <- @characters do %>
        <.avatar size={@size} class="ring-2 ring-white" character={c} />
      <% end %>
    </div>
    """
  end

  defp size_classes(size) do
    case size do
      "xs" -> "h-6 w-6"
      "sm" -> "h-8 w-8"
      "md" -> "h-10 w-10"
      "lg" -> "h-12 w-12"
      "xl" -> "h-14 w-14"
    end
  end

  defp stacked_class(size) do
    case size do
      "xs" -> "-space-x-1"
      _ -> "-space-x-2"
    end
  end

  defp text_size_class(size) do
    case size do
      "xs" -> "text-xs"
      "sm" -> "text-sm"
      "md" -> "text-md"
      "lg" -> "text-lg"
      "xl" -> "text-xl"
    end
  end

  defp initials(name) do
    name
    |> String.split(" ")
    |> Enum.take(2)
    |> Enum.map(& String.first(&1))
    |> Enum.map(& String.upcase(&1))
    |> Enum.join()
  end
end
