defmodule LotdWeb.GalleryView do
  use LotdWeb, :view

  alias Lotd.Gallery.{Item, Room, Display, Region, Location, Mod}

  defp found(_items, _struct, nil), do: nil

  defp found(items, struct, character) do
    case struct do
      %Mod{id: id} ->
        # get items for that mod
        items = Enum.filter(items, & &1.mod_id == id)

        # get collected items for that character
        items
        |> Enum.filter(& Enum.member?(character.items, &1.id))
        |> Enum.count()
    end
  end

  @spec count(any, Lotd.Gallery.Mod.t()) :: non_neg_integer
  defp count(items, struct) do
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

  def visible_mods(mods, search, filter, items, hide, character) do
    # filter search
    mods =
      if String.length(search) >= 3 do
        query = String.downcase(search, :ascii)
        Enum.filter(mods, & String.contains?(String.downcase(&1.name, :ascii), query))
      else
        mods
      end

    mods
    |> Enum.map(& Map.merge(&1, %{
        count: count(items, &1),
        found: found(items, &1, character),
        filtered?: filtered?(filter, &1)
      }))
    |> Enum.reject(& hide && &1.found == &1.count)
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
