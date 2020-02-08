defmodule LotdWeb.Api.ItemView do
  use LotdWeb, :view

  def render("index.json", %{items: items}) do

    displays = Enum.map(items, & &1.display)

    rooms =
      displays
      |> Enum.map(& &1.room)
      |> Enum.map(& {&1.id, [&1.name, &1.url]})
      |> Enum.into(%{})

    displays =
      displays
      |> Enum.map(& {&1.id, [&1.name, &1.url]})
      |> Enum.into(%{})

    locations =
      items
      |> Enum.map(& &1.location)
      |> Enum.reject(& &1 == nil)
      |> Enum.map(& {&1.id, [&1.name, &1.url]})
      |> Enum.into(%{})

    %{
      rooms: rooms,
      displays: displays,
      items: render_many(items, LotdWeb.Api.ItemView, "item.json"),
      locations: locations
    }
  end

  def render("item.json", %{ item: i }) do
    location = unless is_nil(i.location), do: i.location.id, else: nil

    item = [
      i.id,
      i.name,
      i.url,
      i.display.room.id,
      i.display.id,
      location
    ]

    # load collected status for authenticated users
    if Ecto.assoc_loaded?(i.characters) do
      item ++ [ Enum.count(i.characters) == 1 ]
    else
      item
    end
  end
end
