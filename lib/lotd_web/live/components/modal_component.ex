defmodule LotdWeb.ModalComponent do
  use Phoenix.LiveComponent
  use Phoenix.HTML

  import LotdWeb.ViewHelpers
  import LotdWeb.ErrorHelpers

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
            <%= f = form_for @changeset, "#",
            class: form_class(@submitted), novalidate: true,
            phx_change: :validate, phx_submit: :save %>

              <div class="modal-header">
                <h5 class="modal-title">Add Item</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                  <span aria-hidden="true">&times;</span>
                </button>
              </div>

              <div class="modal-body">
                <%= unless is_nil(@changeset.data.id), do: hidden_input f, :id %>

                <%= error(@error) %>
                <%= info(@info) %>

                <div class="form-group">
                  <%= label f, :name %>
                  <%= text_input f, :name,
                    [class: "#{control_class(f, :name)} form-control-sm", placeholder: "Name"] ++ input_validations(f, :name) %>
                  <%= error_tag f, :name %>
                </div>

                <%= if Map.has_key?(@options, :url) do %>
                  <div class="form-group">
                    <%= label f, :url %>
                    <%= text_input f, :url,
                      [class: "form-control form-control-sm", placeholder: "Link"] ++
                      input_validations(f, :url) %>
                    <%= error_tag f, :url %>
                  </div>
                <% end %>

                <%= if Map.has_key?(@options, :display) do %>
                  <div class="form-group">
                    <%= label f, :display_id %>
                    <%= select f, :display_id, options(@options.displays),
                      [class: "form-control form-control-sm", prompt: "Display"] ++
                      input_validations(f, :display_id) %>
                    <%= error_tag f, :display_id %>
                  </div>
                <% end %>

                <%= if Map.has_key?(@options, :mod) do %>
                  <div class="form-group">
                    <%= label f, :mod_id %>
                    <%= select f, :mod_id, options(@options.mods),
                      [class: "form-control form-control-sm", prompt: "Mod"] ++
                      input_validations(f, :mod_id) %>
                    <%= error_tag f, :mod_id %>
                  </div>
                <% end %>

                <%= if Map.has_key?(@options, :locations) do %>
                  <div class="form-group">
                    <%= label f, :location_id %>
                    <%= select f, :location_id, options(@options.locations),
                      [class: "form-control form-control-sm", prompt: "Location"] ++
                      input_validations(f, :location_id) %>
                    <%= error_tag f, :location_id %>
                  </div>
                <% end %>

                <%= if Map.has_key?(@options, :quest) do %>
                  <div class="form-group">
                    <%= label f, :quest_id %>
                    <%= select f, :quest_id, options(@options.quests),
                      [class: "form-control form-control-sm", prompt: "Quest"] ++
                      input_validations(f, :quest_id) %>
                    <%= error_tag f, :quest_id %>
                  </div>
                <% end %>
              </div>
              <div class="modal-footer form-inline justify-content-between">
                <%= unless is_nil(@changeset.data.id) do %>
                  <button id='delete' class='btn btn-danger btn-outline'>Delete</button>
                <% end %>
                <div class='flex-grow-1'></div>
                <%= submit "Save", class: "btn btn-primary", phx_disable_with: "Saving..." %>
              </div>
            </form>
          </div>
        </div>
      </div>
    """
  end
end
