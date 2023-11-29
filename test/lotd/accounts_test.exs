defmodule Lotd.AccountsTest do
  use Lotd.DataCase, async: true

  alias Lotd.Accounts
  alias Lotd.Accounts.User

  test "list_users/0 returns all users" do
    %User{id: id} = user_fixture()
    assert [%User{id: ^id}] = Accounts.list_users()
  end

  test "get_user/1 returns the user with the given id" do
    %User{id: id} = user_fixture()
    assert {:ok, %User{id: ^id}} = Accounts.get_user(id)
  end

  test "get_user!/1 returns the user with the given id" do
    %User{id: id} = user_fixture()
    assert %User{id: ^id} = Accounts.get_user!(id)
  end

  describe "create_user/1 registers a new user" do

    @valid_attrs %{id: 42, name: "some_name"}
    @invalid_attrs %{}

    test "with valid data inserts user" do
      assert {:ok, %User{id: id} = user} = Accounts.create_user(@valid_attrs)
      assert user.id == 42
      assert user.username == "some_name"
      assert user.admin == false
      assert [%User{id: ^id}] = Accounts.list_users()
    end

    test "with invalid data does not insert user" do
      assert {:error, _changeset} = Accounts.create_user(@invalid_attrs)
      assert Accounts.list_users() == []
    end

    test "enforces unique id" do
      assert {:ok, %User{id: id}} = Accounts.create_user(@valid_attrs)
      assert {:error, changeset} = Accounts.create_user(@valid_attrs)
      assert %{id: ["has already been taken"]} = errors_on(changeset)
      assert [%User{id: ^id}] = Accounts.list_users()
    end
  end

  describe "update_user/2 updates a user" do
    setup do
      pUser = user_fixture()

      {:ok, pUser} = Accounts.update_user(pUser, %{admin: true})
      {:ok, user: user_fixture(), privUser: pUser }
    end

    test "make admin", %{user: user} do
      assert {:ok, %User{ admin: true }} = Accounts.update_user(user, %{ admin: true })
    end

    test "demote admin", %{privUser: user} do
      assert {:ok, %User{ admin: false }} = Accounts.update_user(user, %{ admin: false })
    end
  end
end
