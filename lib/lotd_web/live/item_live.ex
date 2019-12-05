defmodule LotdWeb.ItemLive do

  use LotdWeb, :live

  import Lotd.Repo, only: [list_options: 1]

  alias Lotd.{Accounts, Museum}
  alias Lotd.Museum.{Item, Display, Location, Mod, Quest}

  alias LotdWeb.ItemView

  def render(assigns), do: ItemView.render("index.html", assigns)

  def mount(session, socket) do

    Lotd.subscribe("items")

    # get initial options for modal
    socket = assign socket,
      changeset: Museum.change_item(%Item{}),
      options: %{
        displays: list_options(Display),
        locations: list_options(Location),
        mods: list_options(Mod),
        quests: list_options(Quest),
        url: true
      },
      show_modal: false

    # as neither the user or character is changed during the items view we can attach the entire structure once without having to query again and again.
    if session.user_id do
      user = Accounts.get_user!(session.user_id)
      socket = assign socket,
        character_items: Accounts.get_character_items(user.active_character),
        user: user
      {:ok, fetch(socket)}
    else
      socket = assign socket, modal: false
      {:ok, fetch(socket)}
    end
  end

  def handle_event("validate", %{"item" => params}, socket) do
    changeset =
      %Item{}
      |> Museum.change_item(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("add", %{"item" => item }, socket) do
    case Museum.create_item(item) do
      {:ok, _item} ->
        # item = Phoenix.View.render_one(item, DataView, "item.json")
        # Endpoint.broadcast("public", "add-item", item)
        # {:reply, :ok, socket}

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_info({:toggle_modal, _params}, socket) do
    {:noreply, assign(socket, modal: !socket.assigns.modal)}
  end

  def handle_info({ :updated_item, item }, socket) do
    send_update(LotdWeb.ItemComponent, id: item.id, character: socket.assigns.user.active_character)
    {:noreply, socket}
  end

  def handle_info({Lotd, [:item, :saved], item}, socket) do
    item = if authenticated?(socket), do:
      Map.put(item, :found, Museum.item_owned?(item, socket.assigns.user.active_character_id)),
      else: item

    item = item
    |> Map.put(:location, Map.get(socket.assigns.locations, item.location_id))
    |> Map.put(:quest, Map.get(socket.assigns.quests, item.quest_id))
    |> Map.put(:mod, Map.get(socket.assigns.mods, item.mod_id))
    |> Map.put(:display, Map.get(socket.assigns.displays, item.display_id))

    # if element is already in list, replace it, otherwise add it
    items = socket.assigns.items
    if index = Enum.find_index(items, fn i -> i.id == item.id end) do
      # could also do: https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#send_update/2
      {:noreply, assign(socket, :items, List.replace_at(items, index, item))}
    else
      {:noreply, assign(socket, :items, [ item | items ])}
    end
  end

  defp fetch(socket) do
    character = authenticated?(socket) && socket.assigns.user.active_character
    assign(socket, :item_ids, Museum.list_item_ids(character, ""))
  end
end
