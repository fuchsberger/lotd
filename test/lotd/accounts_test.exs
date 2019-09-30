defmodule Lotd.AccountsTest do
  use Lotd.DataCase, async: true

  alias Lotd.Accounts
  alias Lotd.Accounts.User

  describe "user_registration" do

    @valid_attrs %{nexus_id: 42, nexus_name: "some_nexus_name"}
    @invalid_attrs %{}

    test "with valid data inserts user" do
      assert {:ok, %User{id: id}=user} = Accounts.register_user(@valid_attrs)
      assert user.nexus_id == 42
      assert user.nexus_name == "some_nexus_name"
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

  describe "user_roles" do

    setup do
      {:ok, user: user_fixture()}
    end

    test "user should not have moderator or admin roles on creation", %{ user: user } do
      assert user.moderator == false
      assert user.admin == false
    end

    test "promote / demote roles", %{ user: user } do
      {:ok, user} = Accounts.update_user(user, %{ admin: true })
      {:ok, user} = Accounts.update_user(user, %{ moderator: true })
      assert user.admin == true
      assert user.moderator == true
      {:ok, user} = Accounts.update_user(user, %{ admin: false, moderator: false })
      assert user.admin == false
      assert user.moderator == false
    end
  end

  # describe "characters" do
  #   alias Lotd.Accounts.Character

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
  # end
end
