defmodule LotdWeb.LiveHelpers do
  def update_collection(collection, object) do
    collection
    |> Enum.reject(& &1.id == object.id)
    |> List.insert_at(0, object)
    |> Enum.sort_by(&(&1.name))
  end
end
