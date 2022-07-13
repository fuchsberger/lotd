defmodule LotdWeb.Api.CharacterView do
  use LotdWeb, :view

   def render("characters.json", %{characters: characters, active_id: active_id}) do
     %{
       data: render_many(characters, LotdWeb.Api.CharacterView, "character.json", active_id: active_id)
     }
   end

   def render("character.json", %{character: character, active_id: active_id}) do
     [
        character.id == active_id,
        character.name,
        Enum.count(character.items),
        character.inserted_at,
        character.updated_at,
        character.id
     ]
   end
 end
