defmodule LotdWeb.GalleryView do
  use LotdWeb, :view

  alias Lotd.Gallery.{Item, Room, Display, Region, Location, Mod}

  def found(character, struct) do
    case struct do
      %Mod{id: id} ->
        character.items
        |> Enum.filter(& &1 == id)
        |> Enum.count()
    end
  end

  def count(items, struct) do
    case struct do
      %Mod{id: id} ->
        items
        |> Enum.filter(& &1.mod_id == id)
        |> Enum.count()
    end
  end

  def filtered?(nil, _struct), do: false

  def filtered?(filter, struct) do
    filter.__struct__ == struct.__struct__ && filter.id == struct.id
  end

  def type(struct) do
    struct.__struct__
    |> to_string()
    |> String.split(".")
    |> List.last()
  end

  def visible_items(items, search, filter, hide, character) do
    items = cond do
      String.length(search) >= 3 ->
        query = String.downcase(search, :ascii)
        Enum.filter(items, & String.contains?(String.downcase(&1.name, :ascii), query))

      %Mod{} = filter ->
        Enum.filter(items, & &1.mod_id == filter.id)
    end

    if hide, do: Enum.reject(items, & Enum.member?(character.items, &1.id)), else: items
  end
end
