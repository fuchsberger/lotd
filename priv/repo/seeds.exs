# Script for populating the database. You can run it as:
# "mix run priv/repo/seeds.exs" or alternatively "mix ecto reset"
# only run in dev environment or fresh server!

import Lotd.Repo, only: [insert: 1]

alias Lotd.Gallery
alias Lotd.Gallery.{Room, Display, Item, Mod}

# require Logger and hide SQL Messages
require Logger
Logger.configure(level: :info, truncate: 4096)

# attempt to read json content
case File.read("priv/repo/displays.json") do
  {:ok, file} ->
    {:ok, rows} = Jason.decode(file)

    # create rooms
    rows
    |> Enum.map(& &1["roomName"])
    |> Enum.uniq()
    |> Enum.each(& case insert(%Room{ name: &1}) do
        {:ok, _room} -> :ok
        {:error, _changeset} -> Logger.error("Room \"#{&1}\" could not be created.")
      end)

    rooms = Gallery.list_rooms()
    Logger.info("#{Enum.count(rooms)} rooms created.")

    # create displays
    rows
    |> Enum.map(& { &1["roomName"], &1["sectionName"] })
    |> Enum.uniq()
    |> Enum.each(fn {room_name, display_name} ->
      room_id = Enum.find(rooms, & &1.name == room_name).id
      case insert(%Display{ name: display_name, room_id: room_id }) do
        {:ok, _display} -> :ok
        {:error, _changeset} ->
          Logger.warn("Display \"#{room_name} - #{display_name}\" already exists.")
      end
    end)

    displays = Gallery.list_displays()
    Logger.info("#{Enum.count(displays)} displays created.")

    # create mods
    rows
    |> Enum.map(& &1["modSource"])
    |> Enum.uniq()
    |> Enum.each(fn mod ->
      case insert(%Mod{ name: mod }) do
        {:ok, _mod} -> :ok
        {:error, _changeset} ->
          Logger.error("Mod \"#{mod.name}\" could not be created.")
      end
    end)

    mods = Gallery.list_mods()
    Logger.info("#{Enum.count(mods)} mods created.")

    # create items
    Enum.each(rows, fn r ->
      item = %Item{
        name: r["itemName"],
        display_id: Enum.find(displays, & &1.name == r["sectionName"]).id,
        mod_id: Enum.find(mods, & &1.name == r["modSource"]).id
      }
      case insert(item) do
        {:ok, _item} -> :ok
        {:error, _changeset} ->
          Logger.error("Item \"#{r["itemName"]}\" could not be created.")
      end
    end)

    items = Gallery.list_items()
    Logger.info("#{Enum.count(items)} items created.")

  {:error, _posix} ->
    Logger.error("displays.json cannot be opened as it does not seem to exist at the right path.")
end
