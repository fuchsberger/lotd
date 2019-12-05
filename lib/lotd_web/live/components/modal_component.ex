defmodule LotdWeb.ModalComponent do
  use Phoenix.LiveComponent

  # alias Lotd.{Accounts, Museum}
  # alias Lotd.Accounts.Character
  # alias Lotd.Museum.{Display, Item, Location, Mod, Quest}
  # alias Lotd.Repo
  # import Ecto.Query

  def render(assigns) do
    ~L"""
      <div id="modal" class="modal fade" tabindex="-1" role="dialog">
        <div class="modal-dialog" role="document">
          <div class="modal-content">
            <%= live_component @socket, LotdWeb.ItemFormComponent,
              id: "item_changeset", error: nil, info: nil, submitted: false, options: @options,
              changeset: @changeset %>
          </div>
        </div>
      </div>
    """
  end
end
