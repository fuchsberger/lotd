defmodule LotdWeb.ModView do
  use LotdWeb, :view

  alias Lotd.Gallery
  alias Lotd.Gallery.Mod

  def changeset(filter) do
    case filter do
      %Mod{} -> Gallery.change_mod(filter)
      _ -> Gallery.change_mod(%Mod{})
    end
  end

  def filter(mods, struct) do
    case struct do
      %Mod{} -> Enum.find_value(mods, fn mod -> if mod.id == struct.id, do: struct.id end)
      _ -> nil
    end
  end

  def active_mods(mods, character_mod_ids, character_item_ids) do
    mods
    |> Enum.filter(& Enum.member?(character_mod_ids, &1.id))
    |> add_found(character_item_ids)
    |> Enum.reject(& &1.found == Enum.count(&1.items))
  end

  def sort_mods(mods, character_mod_ids, character_item_ids) do
    # first add the found and count to all mods, also always sort legacy mod first
    mods = add_found(mods, character_item_ids)

    active_mods = Enum.filter(mods, & Enum.member?(character_mod_ids, &1.id))
    {
      Enum.reject(active_mods, & &1.found == Enum.count(&1.items)),
      Enum.filter(active_mods, & &1.found == Enum.count(&1.items)),
      Enum.reject(mods, & Enum.member?(character_mod_ids, &1.id))
    }
  end

  defp add_found(mods, character_item_ids) do
    Enum.map(mods, & Map.put(&1, :found,
      MapSet.intersection(MapSet.new(character_item_ids), MapSet.new(&1.items))
      |> MapSet.to_list()
      |> Enum.count()
    ))
  end

  def toggler(mod, type) do
    case type do
      :all -> nil
      :active -> link(icon("active"), to: "#", phx_click: "deactivate", phx_value_id: mod.id)
      :inactive -> link(icon("inactive"), to: "#", phx_click: "activate", phx_value_id: mod.id)
    end
  end
end
