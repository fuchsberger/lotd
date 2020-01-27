defmodule LotdWeb.SettingsView do
  use LotdWeb, :view

  def activated?(character, user) do
    if character.id == user.active_character_id, do: "icon-active", else: "icon-inactive"
  end

  def enabled?(characters, selected_character, mod) do
    mods = mods(characters, selected_character)
    if Enum.find(mods, & &1.id == mod.id), do: "icon-active", else: "icon-inactive"
  end

  def collected_count(selected_character, characters) do
    mod_ids = mods(characters, selected_character) |> Enum.map(& &1.id)

    characters
    |> items(selected_character)
    |> Enum.filter(& Enum.member?(mod_ids, &1.mod_id))
    |> Enum.count()
  end

  def collected_count(selected_character, characters, mod) do
    characters
    |> items(selected_character)
    |> Enum.filter(& &1.mod_id == mod.id)
    |> Enum.count()
  end

  def collectable_count(selected_character, characters, items) do
    mod_ids = mods(characters, selected_character) |> Enum.map(& &1.id)

    items
    |> Enum.filter(& Enum.member?(mod_ids, &1.mod_id))
    |> Enum.count()
  end

  def mod_item_count(m, items) do
    items
    |> Enum.filter(& &1.mod_id == m.id)
    |> Enum.count()
  end

  def selected?(character, selected_character) do
    if character.id == selected_character do
      "list-group-item-secondary"
    else
      ""
    end
  end

  defp items(characters, selected_character) do
    characters
    |> Enum.find(& &1.id == selected_character)
    |> Map.get(:items)
  end

  def mods(characters, selected_character) do
    characters
    |> Enum.find(& &1.id == selected_character)
    |> Map.get(:mods)
  end
end
