defmodule LotdWeb.ModView do
  use LotdWeb, :view

  alias Lotd.Gallery.Mod

  def filter(mods, struct) do
    case struct do
      %Mod{} -> Enum.find_value(mods, fn mod -> if mod.id == struct.id, do: struct.id end)
      _ -> nil
    end
  end

  def sort_mods(mods, character_mod_ids, character_item_ids) do
    # first add the found and count to all mods, also always sort legacy mod first
    mods = Enum.map(mods, & Map.put(&1, :found,
      MapSet.intersection(MapSet.new(character_item_ids), MapSet.new(&1.items))
      |> MapSet.to_list()
      |> Enum.count()
    ))

    active_mods = Enum.filter(mods, & Enum.member?(character_mod_ids, &1.id))
    {
      Enum.reject(active_mods, & &1.found == Enum.count(&1.items)),
      Enum.filter(active_mods, & &1.found == Enum.count(&1.items)),
      Enum.reject(mods, & Enum.member?(character_mod_ids, &1.id))
    }
  end
end
