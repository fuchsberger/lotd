defmodule Lotd.TestHelpers do

  alias Lotd.Accounts

  def user_fixture(attrs \\ %{}) do
    attrs = Enum.into(attrs, %{ id: 10000, name: "test_user" })
    {:ok, user} = Accounts.create_user(attrs)
    user
  end

  def character_fixture(attrs \\ %{}) do
    attrs = Enum.into(attrs, %{ name: "test_character", user_id: 10000 })
    {:ok, character} = Accounts.create_character(attrs)
    character
  end
end
