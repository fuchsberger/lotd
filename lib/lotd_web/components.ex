defmodule LotdWeb.Components do
  defmacro __using__(_) do
    quote do
      alias LotdWeb.Components.Icon

      import LotdWeb.Components.{
        # Alert,
        Avatar,
        Badge,
        Button,
        Card,
        # Container,
        Dropdown,
        Form,
        # Loading,
        # Typography,
        # Avatar,
        # Progress,
        # Breadcrumbs,
        # Pagination,
        Link,
        # Modal,
        # Select,
        SelectMenu,
        # SlideOver,
        # SubHeading,
        Tab,
        Table
        # Toggle,
      }
    end
  end
end
