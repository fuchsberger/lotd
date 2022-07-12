defmodule LotdWeb.ItemView do
  use LotdWeb, :view

  alias Lotd.Accounts.Character

  def sort_icon(assigns) do
    ~H"""
    <div class="group inline-flex">
      <span class="sort-icon ml-2 flex-none rounded">
        <Icon.Solid.chevron_up class="asc h-5 w-5" />
        <Icon.Solid.chevron_down class="desc h-5 w-5" />
      </span>
    </div>
    """
  end

  defp extra_classes(user) do
    case user do
      %{moderator: true, active_character: %Character{}} -> " has-character moderator"
      %{active_character: %Character{}} -> " has-character"
      %{moderator: true} -> " moderator"
      _ -> ""
    end
  end
end
