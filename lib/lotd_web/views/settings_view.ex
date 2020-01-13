defmodule LotdWeb.SettingsView do
  use LotdWeb, :view

  def collected_count(user, mod) do
    user.active_character.items
    |> Enum.filter(fn i -> i.mod_id == mod.id end)
    |> Enum.count()
  end

  def activated?(character, user) do
    if character.id == user.active_character_id, do: "icon-active", else: "icon-inactive"
  end

  def enabled?(characters, selected_character, mod) do
    character = character(characters, selected_character)
    if Enum.find(character.mods, & &1.id == mod.id), do: "icon-active", else: "icon-inactive"
  end

  def found(characters, selected_character, mod) do
    characters
    |> character(selected_character)
    |> Map.get(:items)
    |> Enum.filter(& &1.mod_id == mod.id)
    |> Enum.count()
  end

  def selected?(character, selected_character) do
    if character.id == selected_character do
      "list-group-item-secondary"
    else
      ""
    end
  end

  defp character(characters, id), do: Enum.find(characters, & &1.id == id)
end
