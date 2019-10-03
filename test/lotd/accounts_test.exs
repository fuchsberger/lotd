defmodule Lotd.AccountsTest do
  use Lotd.DataCase, async: true

  alias Lotd.Accounts
  alias Lotd.Accounts.{Character, User}

  test "list_users/0 returns all users" do
    %User{id: id} = user_fixture()
    assert [%User{id: ^id}] = Accounts.list_users()
  end

  test "get_user!/1 returns the user with the given id" do
    %User{id: id} = user_fixture()
    assert %User{id: ^id, active_character: nil} = Accounts.get_user!(id)
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

  describe "update_user/2 updates a user" do
    setup do
      pUser = user_fixture()
      character = character_fixture(pUser)
      {:ok, pUser} = Accounts.update_user(pUser, %{
        admin: true,
        moderator: true,
        active_character_id: character.id
      })

      { :ok, character: character, user: user_fixture(), privUser: pUser }
    end

    test "make admin", %{user: user} do
      assert {:ok, %User{ admin: true }} = Accounts.update_user(user, %{ admin: true })
    end

    test "make moderator", %{user: user} do
      assert {:ok, %User{ moderator: true }} = Accounts.update_user(user, %{ moderator: true })
    end

    test "demote admin", %{privUser: user} do
      assert {:ok, %User{ admin: false }} = Accounts.update_user(user, %{ admin: false })
    end

    test "demote moderator", %{privUser: user} do
      assert {:ok, %User{ moderator: false }} = Accounts.update_user(user, %{ moderator: false })
    end

    test "activate character", %{character: c, user: u} do
      id = c.id
      assert {:ok, %User{ active_character_id: ^id }} =
        Accounts.update_user(u, %{ active_character_id: id })
    end

    test "deactivate character", %{privUser: u} do
      assert {:ok, %User{ active_character_id: nil }} =
        Accounts.update_user(u, %{ active_character_id: nil })
    end
  end

  describe "characters" do
    alias Lotd.Accounts.Character

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    setup do
      {:ok, user: user_fixture()}
    end

    test "list_user_characters/1 returns the users characters with items", %{user: user} do
      %Character{id: id} = character_fixture(user)
      assert [%Character{id: ^id, items: []}] = Accounts.list_user_characters(user)
    end

    test "get_character!/1 returns the character with given id", %{user: user} do
      %Character{id: id} = character_fixture(user)
      assert %Character{id: ^id} = Accounts.get_character!(id)
    end

    test "create_character/1 with valid data creates a character", %{user: user} do
      assert {:ok, %Character{name: name}} = Accounts.create_character(user, @valid_attrs)
      assert name == "some name"
    end

    test "create_character/1 with invalid data returns error changeset", %{user: user} do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_character(user, @invalid_attrs)
    end

    test "update_character/2 with valid data updates the character", %{user: user} do
      character = character_fixture(user, @valid_attrs)
      assert {:ok, %Character{name: name}} = Accounts.update_character(character, @update_attrs)
      assert name == "some updated name"
    end

    test "update_character/2 with invalid data returns error changeset", %{user: user} do
      character = character_fixture(user)
      assert {:error, %Ecto.Changeset{}} = Accounts.update_character(character, @invalid_attrs)
    end

    test "delete_character/1 deletes the character", %{user: user} do
      character = character_fixture(user)
      assert {:ok, %Character{}} = Accounts.delete_character(character)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_character!(character.id) end
    end

    test "change_character/1 returns a character changeset", %{user: user} do
      character = character_fixture(user)
      assert %Ecto.Changeset{} = Accounts.change_character(character)
    end
  end
end
