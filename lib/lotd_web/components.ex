defmodule LotdWeb.Components do
  defmacro __using__(_) do
    quote do
      alias LotdWeb.Components.Icon

      import LotdWeb.Components.{
        Alert,
        Avatar,
        Button,
        Card,
        Dropdown,
        Form,
        Link,
        Tab,
        Table,
        Toggle
      }
    end
  end
end
