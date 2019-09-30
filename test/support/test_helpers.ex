defmodule Lotd.TestHelpers do

  alias Lotd.{Accounts}

  def user_fixture(attrs \\ %{}) do
    id = System.unique_integer([:positive])
    {:ok, user} =
      attrs
      |> Enum.into(%{
        nexus_id: id,
        nexus_name: "user#{id}"
      })
      |> Accounts.register_user()
    user
  end


  def character_fixture(%Accounts.User{} = user, attrs \\ %{}) do
    attrs = Enum.into(attrs, %{ name: "Dovakiin" })
    {:ok, character} = Accounts.create_character(user, attrs)
    character
  end
end
