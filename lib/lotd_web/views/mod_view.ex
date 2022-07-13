defmodule LotdWeb.ModView do
  use LotdWeb, :view

  defp title(:create), do: gettext "Create Mod"
  defp title(:update), do: gettext "Update Mod"
  defp title(:delete), do: gettext "Delete Mod"
end
