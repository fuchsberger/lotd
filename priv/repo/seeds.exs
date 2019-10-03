# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Lotd.Repo.insert!(%Lotd.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Lotd.{Accounts, Gallery, Skyrim}
alias Lotd.Skyrim.Mod
alias Lotd.Gallery.Display

{:ok, user} = Accounts.register_user(%{ nexus_id: 811039, nexus_name: "Sekhmet13" })
Accounts.update_user(user, %{ admin: true, moderator: true })

Accounts.register_user(%{ nexus_id: 0, nexus_name: "Test User" })

# create the basic mods
{:ok, %Mod{id: mid}} = Skyrim.create_mod(%{ name: "Skyrim", filename: "Skyrim.esm" })
Skyrim.create_mod(%{ name: "Dawnguard", filename: "Dawnguard.esm" })
Skyrim.create_mod(%{ name: "Hearth Fires", filename: "HearthFires.esm" })
Skyrim.create_mod(%{ name: "Dragonborn", filename: "Dragonborn.esm" })

# create a few test displays
Gallery.create_display(%{ name: "Hall of Heroes", mod_id: mid })
Gallery.create_display(%{ name: "Dragonborn Hall", mod_id: mid })
Gallery.create_display(%{ name: "Hall of Oddities", mod_id: mid })
{:ok, %Display{id: did}} = Gallery.create_display(%{ name: "Daedric Hall", mod_id: mid })

# create a few test items
Gallery.create_item(%{ name: "Spellbreaker", mod_id: mid, display_id: did })
Gallery.create_item(%{ name: "Ebony Blade", mod_id: mid, display_id: did })
Gallery.create_item(%{ name: "Wabbajack", mod_id: mid, display_id: did })
Gallery.create_item(%{ name: "Ring of Namira", mod_id: mid, display_id: did })
