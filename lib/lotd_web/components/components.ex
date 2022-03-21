defmodule LotdWeb.Components do
  defmacro __using__(_) do
    quote do
      import LotdWeb.Components.{
        Icon,
        Link
      }
    end
  end
end
