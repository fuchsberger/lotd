defmodule Lotd do
  @moduledoc """
  The entrypoint for defining your app logic, such contexts or schemas.

  This can be used in your application as:

      use LotdWeb, :context
      use LotdWeb, :schema

  The definitions below will be executed for every context, schema, etc,
  so keep them short and clean, focused on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions below.
  Instead, define any helper function in modules and import those modules here.
  """

  def context do
    quote do
      import Ecto.Query, warn: false
      import Lotd.LotdHelpers

      alias Ecto.Changeset
      alias Lotd.Accounts.{Group, User}
      alias Lotd.Data.Skill
      alias Lotd.Game.Event
      alias Lotd.PubSub
    end
  end

  def schema do
    quote do
      use Ecto.Schema

      import Ecto.Changeset
      import Lotd.LotdHelpers
      import LotdWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate schema/context/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
