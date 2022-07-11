defmodule LotdWeb.TestView do
  use LotdWeb, :view

  def sort_icon(assigns) do
    ~H"""
    <div class="group inline-flex">
      <span class="sort-icon">
        <Icon.Solid.chevron_up class="asc h-5 w-5" />
        <Icon.Solid.chevron_down class="desc h-5 w-5" />
      </span>
    </div>
    """
  end
end
