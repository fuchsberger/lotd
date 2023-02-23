defmodule LotdWeb.Components do
  defmacro __using__(_) do
    quote do
      alias LotdWeb.Components.Icon

      import LotdWeb.Components.{
        Alert,
        Avatar,
        Button,
        Card,
        Form,
        Icon,
        Modal,
        Tab,
        Toggle
      }
    end
  end
end
