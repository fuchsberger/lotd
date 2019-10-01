defmodule Lotd.AccountsTest do
  use Lotd.DataCase, async: true

  alias Lotd.Accounts
  alias Lotd.Accounts.{Character, User}

  test "list_users/0 lists all users" do
    %User{id: id1} = user_fixture()
    assert [%User{id: ^id1}] = Accounts.list_users()
    %User{id: id2} = user_fixture()
    assert [%User{id: ^id1}, %User{id: ^id2}] = Accounts.list_users()
  end

  test "get_user!/1 returns the user with a given id" do
    %User{id: id} = user_fixture()
    assert %User{id: ^id} = Accounts.get_user!(id)
  end

  test "get_user_by/1 returns a user by one or more attributes" do
    %User{nexus_id: nexus_id} = user_fixture()
    assert %User{nexus_id: ^nexus_id} = Accounts.get_user_by(nexus_id: nexus_id)
  end

  describe "register_user/1 registers a new user" do

    @valid_attrs %{nexus_id: 42, nexus_name: "some_nexus_name"}
    @invalid_attrs %{}

    test "with valid data inserts user" do
      assert {:ok, %User{id: id} = user} = Accounts.register_user(@valid_attrs)
      assert user.nexus_id == 42
      assert user.nexus_name == "some_nexus_name"
      assert user.active_character_id == nil
      assert user.moderator == false
      assert user.admin == false
      assert [%User{id: ^id}] = Accounts.list_users()
    end

    test "with invalid data does not insert user" do
      assert {:error, _changeset} = Accounts.register_user(@invalid_attrs)
      assert Accounts.list_users() == []
    end

    test "enforces unique nexus_id" do
      assert {:ok, %User{id: id}} = Accounts.register_user(@valid_attrs)
      assert {:error, changeset} = Accounts.register_user(@valid_attrs)
      assert %{nexus_id: ["has already been taken"]} = errors_on(changeset)
      assert [%User{id: ^id}] = Accounts.list_users()
    end
  end

  test "update_user/2 updates a user" do
    user = user_fixture()
    {:ok, user} = Accounts.update_user(user, %{ admin: true })
    {:ok, user} = Accounts.update_user(user, %{ moderator: true })
    assert user.admin == true
    assert user.moderator == true
    {:ok, user} = Accounts.update_user(user, %{ admin: false, moderator: false })
    assert user.admin == false
    assert user.moderator == false
  end

  describe "characters" do
    alias Lotd.Accounts.Character

    setup do
      {:ok, user: user_fixture()}
    end

    test "list_user_characters/1", %{user: user} do
      %Character{id: id1} = character_fixture(user)
      assert [%Character{id: ^id1}] = Accounts.list_user_characters(user)
      %Character{id: id2} = character_fixture(user)
      # NOTE: Test could (incorrectly) fail if select retrieves entries in different order
      assert [%Character{id: ^id2}, %Character{id: ^id1}] = Accounts.list_user_characters(user)
    end

    test "get_character!/1" do

    end

  #   @valid_attrs %{name: "some name"}
  #   @update_attrs %{name: "some updated name"}
  #   @invalid_attrs %{name: nil}

  #   def character_fixture(attrs \\ %{}) do
  #     {:ok, character} =
  #       attrs
  #       |> Enum.into(@valid_attrs)
  #       |> Accounts.create_character()

  #     character
  #   end

  #   test "list_characters/0 returns all characters" do
  #     character = character_fixture()
  #     assert Accounts.list_characters() == [character]
  #   end

  #   test "get_character!/1 returns the character with given id" do
  #     character = character_fixture()
  #     assert Accounts.get_character!(character.id) == character
  #   end

  #   test "create_character/1 with valid data creates a character" do
  #     assert {:ok, %Character{} = character} = Accounts.create_character(@valid_attrs)
  #     assert character.name == "some name"
  #   end

  #   test "create_character/1 with invalid data returns error changeset" do
  #     assert {:error, %Ecto.Changeset{}} = Accounts.create_character(@invalid_attrs)
  #   end

  #   test "update_character/2 with valid data updates the character" do
  #     character = character_fixture()
  #     assert {:ok, %Character{} = character} = Accounts.update_character(character, @update_attrs)
  #     assert character.name == "some updated name"
  #   end

  #   test "update_character/2 with invalid data returns error changeset" do
  #     character = character_fixture()
  #     assert {:error, %Ecto.Changeset{}} = Accounts.update_character(character, @invalid_attrs)
  #     assert character == Accounts.get_character!(character.id)
  #   end

  #   test "delete_character/1 deletes the character" do
  #     character = character_fixture()
  #     assert {:ok, %Character{}} = Accounts.delete_character(character)
  #     assert_raise Ecto.NoResultsError, fn -> Accounts.get_character!(character.id) end
  #   end

  #   test "change_character/1 returns a character changeset" do
  #     character = character_fixture()
  #     assert %Ecto.Changeset{} = Accounts.change_character(character)
  #   end
  end
end
