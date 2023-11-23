defmodule LotdWeb.CharacterJSON do
  use LotdWeb, :html

  alias Lotd.Accounts.Character

  @doc """
  Renders a list of characters.
  """
  def index(%{characters: characters, active_id: active_id}) do
    %{data: for(character <- characters, do: data(character, active_id))}
  end

  @doc """
  Renders a single character.
  """
  def show(%{character: character, active_id: active_id}) do
    %{data: data(character, active_id)}
  end

  defp data(%Character{} = character, active_id) do
    [
      character.id == active_id,
      character.name,
      Enum.count(character.items),
      character.inserted_at,
      character.updated_at,
      character.id
    ]
  end
end
