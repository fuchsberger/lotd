defmodule Lotd.TestHelpers do

  alias Lotd.Accounts

  def user_fixture(attrs \\ %{}) do
    attrs = Enum.into(attrs, %{ id: 10000, name: "test_user" })
    {:ok, user} = Accounts.create_user(attrs)
    user
  end
end
