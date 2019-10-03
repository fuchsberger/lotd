# defmodule Lotd.SkyrimTest do
#   use Lotd.DataCase

#   alias Lotd.Skyrim

#   describe "locations" do
#     alias Lotd.Skyrim.Location

#     @valid_attrs %{name: "some name", url: "some url"}
#     @update_attrs %{name: "some updated name", url: "some updated url"}
#     @invalid_attrs %{name: nil, url: nil}

#     def location_fixture(attrs \\ %{}) do
#       {:ok, location} =
#         attrs
#         |> Enum.into(@valid_attrs)
#         |> Skyrim.create_location()

#       location
#     end

#     test "list_locations/0 returns all locations" do
#       location = location_fixture()
#       assert Skyrim.list_locations() == [location]
#     end

#     test "get_location!/1 returns the location with given id" do
#       location = location_fixture()
#       assert Skyrim.get_location!(location.id) == location
#     end

#     test "create_location/1 with valid data creates a location" do
#       assert {:ok, %Location{} = location} = Skyrim.create_location(@valid_attrs)
#       assert location.name == "some name"
#       assert location.url == "some url"
#     end

#     test "create_location/1 with invalid data returns error changeset" do
#       assert {:error, %Ecto.Changeset{}} = Skyrim.create_location(@invalid_attrs)
#     end

#     test "update_location/2 with valid data updates the location" do
#       location = location_fixture()
#       assert {:ok, %Location{} = location} = Skyrim.update_location(location, @update_attrs)
#       assert location.name == "some updated name"
#       assert location.url == "some updated url"
#     end

#     test "update_location/2 with invalid data returns error changeset" do
#       location = location_fixture()
#       assert {:error, %Ecto.Changeset{}} = Skyrim.update_location(location, @invalid_attrs)
#       assert location == Skyrim.get_location!(location.id)
#     end

#     test "delete_location/1 deletes the location" do
#       location = location_fixture()
#       assert {:ok, %Location{}} = Skyrim.delete_location(location)
#       assert_raise Ecto.NoResultsError, fn -> Skyrim.get_location!(location.id) end
#     end

#     test "change_location/1 returns a location changeset" do
#       location = location_fixture()
#       assert %Ecto.Changeset{} = Skyrim.change_location(location)
#     end
#   end

#   describe "quests" do
#     alias Lotd.Skyrim.Quest

#     @valid_attrs %{name: "some name", url: "some url"}
#     @update_attrs %{name: "some updated name", url: "some updated url"}
#     @invalid_attrs %{name: nil, url: nil}

#     def quest_fixture(attrs \\ %{}) do
#       {:ok, quest} =
#         attrs
#         |> Enum.into(@valid_attrs)
#         |> Skyrim.create_quest()

#       quest
#     end

#     test "list_quests/0 returns all quests" do
#       quest = quest_fixture()
#       assert Skyrim.list_quests() == [quest]
#     end

#     test "get_quest!/1 returns the quest with given id" do
#       quest = quest_fixture()
#       assert Skyrim.get_quest!(quest.id) == quest
#     end

#     test "create_quest/1 with valid data creates a quest" do
#       assert {:ok, %Quest{} = quest} = Skyrim.create_quest(@valid_attrs)
#       assert quest.name == "some name"
#       assert quest.url == "some url"
#     end

#     test "create_quest/1 with invalid data returns error changeset" do
#       assert {:error, %Ecto.Changeset{}} = Skyrim.create_quest(@invalid_attrs)
#     end

#     test "update_quest/2 with valid data updates the quest" do
#       quest = quest_fixture()
#       assert {:ok, %Quest{} = quest} = Skyrim.update_quest(quest, @update_attrs)
#       assert quest.name == "some updated name"
#       assert quest.url == "some updated url"
#     end

#     test "update_quest/2 with invalid data returns error changeset" do
#       quest = quest_fixture()
#       assert {:error, %Ecto.Changeset{}} = Skyrim.update_quest(quest, @invalid_attrs)
#       assert quest == Skyrim.get_quest!(quest.id)
#     end

#     test "delete_quest/1 deletes the quest" do
#       quest = quest_fixture()
#       assert {:ok, %Quest{}} = Skyrim.delete_quest(quest)
#       assert_raise Ecto.NoResultsError, fn -> Skyrim.get_quest!(quest.id) end
#     end

#     test "change_quest/1 returns a quest changeset" do
#       quest = quest_fixture()
#       assert %Ecto.Changeset{} = Skyrim.change_quest(quest)
#     end
#   end
# end
