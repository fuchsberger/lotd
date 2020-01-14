# Script for populating the database. You can run it as:
# "mix run priv/repo/seeds.exs" or alternatively "mix ecto reset"
# only run in dev environment!


alias Lotd.Gallery
# alias Lotd.{Accounts, Gallery}
# alias Lotd.Accounts.Character

# require Logger and hide SQL Messages
require Logger
Logger.configure(level: :info, truncate: 4096)

# # attempt to create admin user
# case Accounts.register_user(%{ id: 811039, name: "Sekhmet13" }) do
#   {:ok, user} ->
#     {:ok, %Character{id: id}} = Accounts.create_character(user, %{name: "Default"})
#     Accounts.update_user(user, %{ admin: true, moderator: true, active_character_id: id })
#     Logger.info("Admin user created.")
#   {:error, _changeset} ->
#     Logger.info("Admin user has not been created as it already exists")
# end

# # attempt to create a test user (can never login)
# case Accounts.register_user(%{ id: 0, name: "Test User" }) do
#   {:ok, user} ->
#     {:ok, %Character{id: id}} = Accounts.create_character(user, %{name: "Default"})
#     Accounts.update_user(user, %{ active_character_id: id })
#     Logger.info("Test user created.")
#   {:error, _changeset} ->
#     Logger.info("Test user has not been created as it already exists")
# end

# attempt to read json content
case File.read("priv/repo/displays.json") do
  {:ok, file} ->
    {:ok, rows} = Jason.decode(file)

    # create displays
    rows
    |> Enum.map(& &1["sectionName"])
    |> Enum.uniq()
    |> Enum.each(fn display ->
      case Gallery.create_display(%{ name: display }) do
        {:ok, display} ->
          Logger.info("Display \"#{display.name}\" created.")
        {:error, _changeset} ->
          Logger.info("Display \"#{display}\" already exists.")
      end
    end)

    # create mods
    rows
    |> Enum.map(& &1["modSource"])
    |> Enum.uniq()
    |> Enum.each(fn mod ->
      case Gallery.create_mod(%{ name: mod }) do
        {:ok, mod} ->
          Logger.info("Mod \"#{mod.name}\" created.")
        {:error, _changeset} ->
          Logger.warn("Mod \"#{mod.name}\" already exists.")
      end
    end)

    # create items
    Enum.each(rows, fn item ->
      item = %{
        name: item["itemName"],
        room: Gallery.get_room_id!(item["roomName"]),
        display_id: Gallery.get_display_id!(item["sectionName"]),
        mod_id: Gallery.get_mod_id!(item["modSource"])
      }

      case Gallery.create_item(item) do
        {:ok, item} ->
          Logger.info("Item \"#{item.name}\" created.")
        {:error, _changeset} ->
          Logger.error("Item \"#{item.name}\" could not be created.")
      end
    end)

  {:error, _posix} ->
    Logger.error("displays.json cannot be opened as it does not seem to exist at the right path.")
end
