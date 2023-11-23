defmodule LotdWeb.ModJSON do
  use LotdWeb, :html

  alias Lotd.Gallery.Mod

  @doc """
  Renders a list of mods.
  """
  def index(%{mods: mods, user_mod_ids: mids}) do
    %{data: for(mod <- mods, do: data(mod, mids))}
  end

  @doc """
  Renders a single mod.
  """
  def show(%{mod: mod, user_mod_ids: mids}) do
    %{data: data(mod, mids)}
  end

  defp data(%Mod{} = mod, user_mod_ids) do
    [
      mod.id in user_mod_ids,
      mod.name,
      Enum.count(mod.items),
      Enum.count(mod.users),
      mod.url,
      mod.id
   ]
  end
end
