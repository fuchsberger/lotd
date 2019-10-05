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
alias Lotd.Accounts.Character
alias Lotd.Skyrim.{Quest, Location, Mod}
alias Lotd.Gallery.Display

# create admin user
{:ok, user} = Accounts.register_user(%{ nexus_id: 811039, nexus_name: "Sekhmet13" })
{:ok, %Character{id: id}} = Accounts.create_character(user, %{name: "Default"})
Accounts.update_user(user, %{ admin: true, moderator: true, active_character_id: id })

# create a test user (can never login)
{:ok, user} = Accounts.register_user(%{ nexus_id: 0, nexus_name: "Test User" })
{:ok, %Character{id: id}} = Accounts.create_character(user, %{name: "Default"})
Accounts.update_user(user, %{ active_character_id: id })

# create the basic mods
{:ok, %Mod{id: mid}} = Skyrim.create_mod(%{
  name: "Skyrim",
  url: "https://en.uesp.net/wiki/Skyrim:Skyrim",
  filename: "Skyrim.esm"
})
Skyrim.create_mod(%{
  name: "Dawnguard",
  url: "https://en.uesp.net/wiki/Skyrim:Dawnguard",
  filename: "Dawnguard.esm"
})
Skyrim.create_mod(%{
  name: "Hearthfire",
  url: "https://en.uesp.net/wiki/Skyrim:Hearthfire",
  filename: "HearthFires.esm"
})
{:ok, %Mod{id: db}} = Skyrim.create_mod(%{
  name: "Dragonborn",
  url: "https://en.uesp.net/wiki/Dragonborn:Dragonborn",
  filename: "Dragonborn.esm"
})
Skyrim.create_mod(%{
  name: "Legacy of the Dragonborn",
  url: "https://www.nexusmods.com/skyrimspecialedition/mods/11802",
  filename: "LegacyoftheDragonborn.esm"
})

# create a few test displays
{:ok, %Display{id: h_heroes}} =Gallery.create_display(%{ name: "Hall of Heroes", mod_id: mid })
Gallery.create_display(%{ name: "Dragonborn Hall", mod_id: mid })
Gallery.create_display(%{ name: "Hall of Oddities", mod_id: mid })
{:ok, %Display{id: daedric_hall}} = Gallery.create_display(%{ name: "Daedric Hall", mod_id: mid })

# create a few test quests
{:ok, %Quest{id: quest}} = Skyrim.create_quest(%{
  name: "At the Summit of Apocrypha",
  url: "https://en.uesp.net/wiki/Dragonborn:At_the_Summit_of_Apocrypha",
  mod_id: db
})

# create a few test locations
{:ok, %Location{id: location}} = Skyrim.create_location(%{
  name: "Apocrypha (Waking Dreams)",
  url: "https://en.uesp.net/wiki/Dragonborn:Apocrypha_(Waking_Dreams)",
  mod_id: db
})

# create a few test items
Gallery.create_item(%{ name: "Spellbreaker", mod_id: mid, display_id: daedric_hall })
Gallery.create_item(%{ name: "Ebony Blade", mod_id: mid, display_id: daedric_hall })
Gallery.create_item(%{ name: "Wabbajack", mod_id: mid, display_id: daedric_hall })
Gallery.create_item(%{ name: "Ring of Namira", mod_id: mid, display_id: daedric_hall })

Gallery.create_item(%{ name: "Bloodskal Blade", mod_id: db, display_id: h_heroes })
Gallery.create_item(%{ name: "Dwarven Black Bow of Fate", mod_id: db, display_id: h_heroes })

Gallery.create_item(%{
  name: "Miraak's Staff",
  quest_id: quest,
  mod_id: db,
  display_id: h_heroes,
  location_id: location
})

Gallery.create_item(%{
  name: "Miraak's Sword",
  quest_id: quest,
  mod_id: db,
  display_id: h_heroes,
  location_id: location
})
