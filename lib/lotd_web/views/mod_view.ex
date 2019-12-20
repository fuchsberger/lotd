defmodule LotdWeb.ModView do
  use LotdWeb, :view

  def collected_count(user, mod) do
    user.active_character.items
    |> Enum.filter(fn i -> i.mod_id == mod.id end)
    |> Enum.count()
  end

  def hidden?(mod, search) do
    not String.contains?(String.downcase(mod.name), String.downcase(search))
  end
end
