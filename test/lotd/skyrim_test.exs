# defmodule Lotd.SkyrimTest do
#   use Lotd.DataCase

#   alias Lotd.Skyrim

#   describe "locations" do
#     alias Lotd.Museum.Location

#     @valid_attrs %{name: "some name", url: "some url"}
#     @update_attrs %{name: "some updated name", url: "some updated url"}
#     @invalid_attrs %{name: nil, url: nil}

#     def location_fixture(attrs \\ %{}) do
#       {:ok, location} =
#         attrs
#         |> Enum.into(@valid_attrs)
#         |> Museum.create_location()

#       location
#     end

#     test "list_locations/0 returns all locations" do
#       location = location_fixture()
#       assert Museum.list_locations() == [location]
#     end

#     test "get_location!/1 returns the location with given id" do
#       location = location_fixture()
#       assert Museum.get_location!(location.id) == location
#     end

#     test "create_location/1 with valid data creates a location" do
#       assert {:ok, %Location{} = location} = Museum.create_location(@valid_attrs)
#       assert location.name == "some name"
#       assert location.url == "some url"
#     end

#     test "create_location/1 with invalid data returns error changeset" do
#       assert {:error, %Ecto.Changeset{}} = Museum.create_location(@invalid_attrs)
#     end

#     test "update_location/2 with valid data updates the location" do
#       location = location_fixture()
#       assert {:ok, %Location{} = location} = Museum.update_location(location, @update_attrs)
#       assert location.name == "some updated name"
#       assert location.url == "some updated url"
#     end

#     test "update_location/2 with invalid data returns error changeset" do
#       location = location_fixture()
#       assert {:error, %Ecto.Changeset{}} = Museum.update_location(location, @invalid_attrs)
#       assert location == Museum.get_location!(location.id)
#     end

#     test "delete_location/1 deletes the location" do
#       location = location_fixture()
#       assert {:ok, %Location{}} = Museum.delete_location(location)
#       assert_raise Ecto.NoResultsError, fn -> Museum.get_location!(location.id) end
#     end

#     test "change_location/1 returns a location changeset" do
#       location = location_fixture()
#       assert %Ecto.Changeset{} = Museum.change_location(location)
#     end
#   end

#   describe "quests" do
#     alias Lotd.Museum.Quest

#     @valid_attrs %{name: "some name", url: "some url"}
#     @update_attrs %{name: "some updated name", url: "some updated url"}
#     @invalid_attrs %{name: nil, url: nil}

#     def quest_fixture(attrs \\ %{}) do
#       {:ok, quest} =
#         attrs
#         |> Enum.into(@valid_attrs)
#         |> Museum.create_quest()

#       quest
#     end

#     test "list_quests/0 returns all quests" do
#       quest = quest_fixture()
#       assert Museum.list_quests() == [quest]
#     end

#     test "get_quest!/1 returns the quest with given id" do
#       quest = quest_fixture()
#       assert Museum.get_quest!(quest.id) == quest
#     end

#     test "create_quest/1 with valid data creates a quest" do
#       assert {:ok, %Quest{} = quest} = Museum.create_quest(@valid_attrs)
#       assert quest.name == "some name"
#       assert quest.url == "some url"
#     end

#     test "create_quest/1 with invalid data returns error changeset" do
#       assert {:error, %Ecto.Changeset{}} = Museum.create_quest(@invalid_attrs)
#     end

#     test "update_quest/2 with valid data updates the quest" do
#       quest = quest_fixture()
#       assert {:ok, %Quest{} = quest} = Museum.update_quest(quest, @update_attrs)
#       assert quest.name == "some updated name"
#       assert quest.url == "some updated url"
#     end

#     test "update_quest/2 with invalid data returns error changeset" do
#       quest = quest_fixture()
#       assert {:error, %Ecto.Changeset{}} = Museum.update_quest(quest, @invalid_attrs)
#       assert quest == Museum.get_quest!(quest.id)
#     end

#     test "delete_quest/1 deletes the quest" do
#       quest = quest_fixture()
#       assert {:ok, %Quest{}} = Museum.delete_quest(quest)
#       assert_raise Ecto.NoResultsError, fn -> Museum.get_quest!(quest.id) end
#     end

#     test "change_quest/1 returns a quest changeset" do
#       quest = quest_fixture()
#       assert %Ecto.Changeset{} = Museum.change_quest(quest)
#     end
#   end
#
  describe "mods" do
    alias Lotd.Museum.Mod

    @valid_attrs %{filename: "some filename", name: "some name", url: "some url"}
    @update_attrs %{filename: "some updated filename", name: "some updated name", url: "some updated url"}
    @invalid_attrs %{filename: nil, name: nil, url: nil}

    def mod_fixture(attrs \\ %{}) do
      {:ok, mod} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Museum.create_mod()

      mod
    end

    test "list_mods/0 returns all mods" do
      mod = mod_fixture()
      assert Museum.list_mods() == [mod]
    end

    test "get_mod!/1 returns the mod with given id" do
      mod = mod_fixture()
      assert Museum.get_mod!(mod.id) == mod
    end

    test "create_mod/1 with valid data creates a mod" do
      assert {:ok, %Mod{} = mod} = Museum.create_mod(@valid_attrs)
      assert mod.filename == "some filename"
      assert mod.name == "some name"
      assert mod.url == "some url"
    end

    test "create_mod/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Museum.create_mod(@invalid_attrs)
    end

    test "update_mod/2 with valid data updates the mod" do
      mod = mod_fixture()
      assert {:ok, %Mod{} = mod} = Museum.update_mod(mod, @update_attrs)
      assert mod.filename == "some updated filename"
      assert mod.name == "some updated name"
      assert mod.url == "some updated url"
    end

    test "update_mod/2 with invalid data returns error changeset" do
      mod = mod_fixture()
      assert {:error, %Ecto.Changeset{}} = Museum.update_mod(mod, @invalid_attrs)
      assert mod == Museum.get_mod!(mod.id)
    end

    test "delete_mod/1 deletes the mod" do
      mod = mod_fixture()
      assert {:ok, %Mod{}} = Museum.delete_mod(mod)
      assert_raise Ecto.NoResultsError, fn -> Museum.get_mod!(mod.id) end
    end

    test "change_mod/1 returns a mod changeset" do
      mod = mod_fixture()
      assert %Ecto.Changeset{} = Museum.change_mod(mod)
    end
  end
end
