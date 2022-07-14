defmodule LotdWeb.Api.ModView do
  use LotdWeb, :view

   def render("mods.json", %{mods: mods, user_mod_ids: mids}) do
     %{
       data: render_many(mods, LotdWeb.Api.ModView, "mod.json", user_mod_ids: mids)
     }
   end

   def render("mod.json", %{mod: mod, user_mod_ids: mids}) do
     [
        mod.id in mids,
        mod.name,
        Enum.count(mod.items),
        Enum.count(mod.users),
        mod.url,
        mod.id
     ]
   end
 end
