defmodule LotdWeb.UserLive do
  use Phoenix.LiveView, container: {:div, class: "container"}

  alias Lotd.Accounts

  def render(assigns), do: LotdWeb.UserView.render("index.html", assigns)

  def mount(_params, session, socket) do
    users = Accounts.list_users()
    admin = Enum.find(users, & &1.id == session["user_id"]).admin

    {:ok, assign(socket, admin: admin, users: users )}
  end

  def handle_event("toggle", %{"admin" => value, "id" => id}, socket) do
    user = Enum.find(socket.assigns.users, & &1.id == String.to_integer(id))
    value = if value == "true", do: false, else: true

    case Accounts.update_user(user, %{admin: value}) do
      {:ok, user} ->
        users =
          socket.assigns.users
          |> Enum.reject(& &1.id == user.id)
          |> List.insert_at(0, user)
          |> Enum.sort_by(&(&1.name))
        {:noreply, assign(socket, users: users)}

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  def handle_event("toggle", %{"moderator" => value, "id" => id}, socket) do
    user = Enum.find(socket.assigns.users, & &1.id == String.to_integer(id))
    value = if value == "true", do: false, else: true

    case Accounts.update_user(user, %{moderator: value}) do
      {:ok, user} ->
        users =
          socket.assigns.users
          |> Enum.reject(& &1.id == user.id)
          |> List.insert_at(0, user)
          |> Enum.sort_by(&(&1.name))
        {:noreply, assign(socket, users: users)}

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end
end
