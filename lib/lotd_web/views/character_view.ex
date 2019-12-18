defmodule LotdWeb.CharacterView do
  use LotdWeb, :view

  def collected_count(user, mod) do
    user.active_character.items
    |> Enum.filter(fn i -> i.mod_id == mod.id end)
    |> Enum.count()
  end
end
