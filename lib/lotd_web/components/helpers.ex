defmodule LotdWeb.Components.UI.Helpers do
  @moduledoc """
  Helpers for UI Components
  """

  @doc """
  Joins together different classes into a single class string.

  ```ex
  classes(["bg-gray-400", "text-red-100"])
  "bg-gray-400 text-red-100"
  ```
  """
  def classes(list) when is_list(list) do
    list
    |> Enum.filter(& is_binary(&1))
    |> Enum.reject(& &1 == "")
    |> Enum.map(& String.trim(&1))
    |> Enum.join(" ")
  end

  def focus_classes, do: "focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500"
end
