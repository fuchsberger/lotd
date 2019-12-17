# Script for populating the database. You can run it as:
# mix run priv/repo/seeds.exs

alias Lotd.{Accounts, Museum}
alias Lotd.Accounts.Character

# require Logger and hide SQL Messages
require Logger
Logger.configure(level: :info, truncate: 4096)

# attempt to create admin user
case Accounts.register_user(%{ nexus_id: 811039, nexus_name: "Sekhmet13" }) do
  {:ok, user} ->
    {:ok, %Character{id: id}} = Accounts.create_character(user, %{name: "Default"})
    Accounts.update_user(user, %{ admin: true, moderator: true, active_character_id: id })
    Logger.info("Admin user created.")
  {:error, _changeset} ->
    Logger.info("Admin user has not been created as it already exists")
end

# attempt to create a test user (can never login)
case Accounts.register_user(%{ nexus_id: 0, nexus_name: "Test User" }) do
  {:ok, user} ->
    {:ok, %Character{id: id}} = Accounts.create_character(user, %{name: "Default"})
    Accounts.update_user(user, %{ active_character_id: id })
    Logger.info("Test user created.")
  {:error, _changeset} ->
    Logger.info("Test user has not been created as it already exists")
end

# attempt to read json content
case File.read("priv/repo/displays.json") do
  {:ok, file} ->
    {:ok, rows} = Jason.decode(file)

    # create displays
    displays = Enum.map(rows, fn d ->
      %{name: d["sectionName"], room: Museum.get_room_number(d["roomName"])}
    end)
    |> Enum.uniq()
    |> Enum.each(fn display ->
      case Museum.create_display(display) do
        {:ok, display} ->
          Logger.info("Display \"#{display.name}\" created.")
        {:error, _changeset} ->
          Logger.info("Display \"#{display.name}\" already exists.")
      end
    end)

    # create mods
    mods = Enum.map(rows, fn d -> d["modSource"] end)
    |> Enum.uniq()
    |> Enum.map(fn mod -> %{name: mod} end)
    |> Enum.each(fn mod ->
      case Museum.create_mod(mod) do
        {:ok, mod} ->
          Logger.info("Mod \"#{mod.name}\" created.")
        {:error, _changeset} ->
          Logger.info("Mod \"#{mod.name}\" already exists.")
      end
    end)

    # create items
    Enum.each(rows, fn item ->
      item = %{
        name: item["itemName"],
        form_id: Museum.get_form_id(item["formId"]),
        replica_id: Museum.get_form_id(item["replicaId"]),
        display_ref: Museum.get_form_id(item["displayRef"]),
        display_id: Museum.get_display_id!(item["sectionName"]),
        mod_id: Museum.get_mod_id!(item["modSource"])
      }

      case Museum.create_item(item) do
        {:ok, item} ->
          Logger.info("Item \"#{item.name}\" created.")
        {:error, _changeset} ->
          Logger.info("Item \"#{item.name}\" already exists.")
      end
    end)

  {:error, _posix} ->
    Logger.error("displays.json cannot be opened as it does not seem to exist at the right path.")
end
